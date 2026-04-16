---
name: ios-localization-sync
description: Use when a task changes iOS user-facing copy, UI labels, alerts, notifications, widget text, or theme names in this repo. Syncs the string catalog, checks missing translations, and verifies that newly added or changed copy is localized for zh-Hans and en before finishing.
---

# iOS Localization Sync

Use this skill whenever a task changes user-facing copy in the app or widget.

Scope:
- SwiftUI page titles, section titles, buttons, labels, placeholders
- Alert titles and messages
- Notification and AlarmKit copy
- Live Activity / widget text
- Theme display names and marketing taglines

## Workflow

1. Apply the product/code change first.
2. Prefer stable localization keys for any string that becomes a plain `String` at runtime.
3. Run:

```bash
python3 scripts/i18n_sync_catalog.py
python3 scripts/i18n_scan.py
python3 scripts/i18n_check.py
```

4. If `i18n_scan.py` reports missing translations:
- add or fix the relevant explicit `String(localized:..., defaultValue:...)` calls
- if needed, extend `EN_OVERRIDES` in `scripts/i18n_sync_catalog.py`
- rerun the three commands

5. If the task changed app/widget sources or localized resources, make sure:
- `LazyButNot/Localizable.xcstrings` is still included in the app target and widget target
- any new shared source needed by the widget is also added to both targets

6. Before finishing, also run a build when the task changed UI or notification code:

```bash
xcodebuild -project /Users/kl/Desktop/kunlunLibray/flutter/懒人不懒/LazyButNot/LazyButNot.xcodeproj -scheme LazyButNot build
```

## Repo Conventions

- This repo supports `zh-Hans` and `en`.
- The app is unreleased; enum persistence compatibility is not a constraint right now.
- `rawValue` may be stable codes, but UI must use localized display properties.
- Do not assume bare runtime `String` values will localize correctly. If a string flows through state, service code, computed properties, or model display helpers, make it explicit with `String(localized:..., defaultValue:...)`.
