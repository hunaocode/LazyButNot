import importlib.util
import tempfile
import unittest
from pathlib import Path
from unittest import mock


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "i18n_sync_catalog.py"
SPEC = importlib.util.spec_from_file_location("i18n_sync_catalog", SCRIPT_PATH)
i18n_sync_catalog = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(i18n_sync_catalog)


class SwiftFileDiscoveryTests(unittest.TestCase):
    def test_excludes_test_target_directories(self):
        with tempfile.TemporaryDirectory() as temporary_directory:
            swift_root = Path(temporary_directory)
            source_files = {
                "App/HomeView.swift": 'let title = "首页"',
                "LazyButNotTests/AppTests.swift": '@Test("应用模块可以加载")',
                "LazyButNotUITests/AppUITests.swift": 'let name = "首页可以显示"',
                "Packages/Feature/Tests/FeatureTests.swift": 'let name = "功能测试"',
            }
            for relative_path, content in source_files.items():
                path = swift_root / relative_path
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content, encoding="utf-8")

            with mock.patch.object(i18n_sync_catalog, "SWIFT_ROOT", swift_root):
                discovered = {
                    path.relative_to(swift_root).as_posix()
                    for path in i18n_sync_catalog.iter_swift_files()
                }
                entries = i18n_sync_catalog.collect_entries()

            self.assertEqual(discovered, {"App/HomeView.swift"})
            self.assertEqual(entries, {"首页": "首页"})


if __name__ == "__main__":
    unittest.main()
