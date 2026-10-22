import contextlib
import importlib.util
import io
from pathlib import Path
import sys
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('asc_upload', ROOT / 'upload_localizations.py')
asc = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = asc
spec.loader.exec_module(asc)


class UploadSafetyTests(unittest.TestCase):
    def setUp(self):
        _, app, upload = asc.load_config(ROOT / 'config/app_store_connect.example.json')
        self.client = Mock()
        self.uploader = asc.AppStoreMetadataUploader(
            self.client, app, upload, dry_run=False, selected_locales=set(),
            skip_metadata=False, skip_screenshots=False,
        )
        self.plan = self.uploader._load_locale_plans()[0]

    def test_offline_check_never_creates_client(self):
        with patch.object(sys, 'argv', ['upload', '--config', str(ROOT / 'config/app_store_connect.example.json'), '--check']), patch.object(asc, 'AppStoreConnectClient') as client, contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(asc.main(), 0)
            client.assert_not_called()

    def test_default_is_preview(self):
        with patch.object(sys, 'argv', ['upload', '--config', 'example.json']):
            args = asc.parse_args()
            self.assertFalse(args.apply)
            self.assertFalse(args.with_screenshots)

    def test_apply_cannot_combine_with_preview(self):
        with patch.object(sys, 'argv', ['upload', '--config', 'x', '--apply', '--dry-run']), contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            asc.parse_args()

    def test_preview_does_not_write(self):
        self.uploader._dry_run = True
        with contextlib.redirect_stdout(io.StringIO()):
            self.uploader._update_app_info_localization(self.plan, {'id': 'info'})
            self.uploader._update_version_localization(self.plan, {'id': 'version'})
            self.uploader._sync_screenshots(self.plan, {'id': 'version'})
        self.client.request_json.assert_not_called()
        self.client.upload_bytes.assert_not_called()

    def test_existing_screenshots_are_not_deleted(self):
        self.uploader._ensure_screenshot_set = Mock(return_value={'id': 'set'})
        self.client.list_all.return_value = [{'id': 'existing'}]
        self.uploader._clear_screenshot_set = Mock()
        self.uploader._upload_single_screenshot = Mock()
        with self.assertRaises(ValueError):
            self.uploader._sync_screenshots(self.plan, {'id': 'version'})
        self.uploader._clear_screenshot_set.assert_not_called()
        self.uploader._upload_single_screenshot.assert_not_called()

    def test_count_mismatch_does_not_delete_or_retry(self):
        self.client.list_all.return_value = []
        screenshots = self.uploader._build_screenshot_plans(self.plan)[0]
        with contextlib.redirect_stdout(io.StringIO()), self.assertRaises(RuntimeError):
            self.uploader._verify_and_repair_screenshot_set('set', screenshots)
        self.client.request_json.assert_not_called()
        self.client.upload_bytes.assert_not_called()

    def test_readback_mismatch_fails(self):
        self.client.request_json.return_value = {'data': {'attributes': {'subtitle': 'old'}}}
        with self.assertRaises(RuntimeError):
            self.uploader._verify_metadata('/v1/appInfoLocalizations/info', {'subtitle': 'new'})

    def test_bundle_mismatch_fails(self):
        with self.assertRaises(ValueError):
            self.uploader._validate_bundle_id({'attributes': {'bundleId': 'other.app'}})

    def test_two_locales_and_sixteen_images(self):
        plans = self.uploader._load_locale_plans()
        self.assertEqual({p.locale for p in plans}, {'en-US', 'zh-Hans'})
        sets = [s for p in plans for s in self.uploader._build_screenshot_plans(p)]
        self.assertEqual(len(sets), 4)
        self.assertEqual(sum(len(s.files) for s in sets), 16)
        self.assertTrue(all(not s.clear_before_upload for s in sets))


if __name__ == '__main__':
    unittest.main()
