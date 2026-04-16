#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    subprocess.run([sys.executable, str(ROOT / "scripts" / "i18n_sync_catalog.py")], check=True)
    result = subprocess.run(
        [sys.executable, str(ROOT / "scripts" / "i18n_scan.py")],
        check=True,
        capture_output=True,
        text=True,
    )
    payload = json.loads(result.stdout)
    missing = payload.get("missing_translations", [])
    if missing:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        sys.exit(1)
    print("i18n check passed")


if __name__ == "__main__":
    main()
