#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "LazyButNot" / "Localizable.xcstrings"
CJK_RE = re.compile(r"[\u4e00-\u9fff]")


def main():
    if not CATALOG_PATH.exists():
        print(json.dumps({"missing_catalog": True}, ensure_ascii=False, indent=2))
        return

    catalog = json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    strings = catalog.get("strings", {})
    missing = []

    for key, entry in sorted(strings.items()):
        localizations = entry.get("localizations", {})
        zh = localizations.get("zh-Hans", {}).get("stringUnit", {}).get("value")
        en = localizations.get("en", {}).get("stringUnit", {}).get("value")
        if zh and en and zh == en and not CJK_RE.search(zh):
            continue
        if not zh or not en or zh == en:
            missing.append({"key": key, "zh-Hans": zh, "en": en})

    print(json.dumps({"missing_translations": missing}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
