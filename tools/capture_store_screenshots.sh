#!/bin/bash
# Capture only from a booted simulator with the Debug screenshot entry enabled.
# Usage: bash tools/capture_store_screenshots.sh <udid> <iphone|ipad> <zh-Hans|en> <artifact-root>
set -euo pipefail
device_id="$1"
device_kind="$2"
language="$3"
artifact_root="$4"
case "$device_kind" in iphone|ipad) ;; *) exit 2 ;; esac
case "$language" in
  zh-Hans) app_language=zhHans; app_locale=zh_CN ;;
  en) app_language=english; app_locale=en_US ;;
  *) exit 2 ;;
esac
app_id=com.hunaocode.LazyButNot
container=$(xcrun simctl get_app_container "$device_id" "$app_id" data)
xcrun simctl terminate "$device_id" "$app_id" >/dev/null 2>&1 || true
swift tools/seed_store_screenshots.swift "$container" "$language"
xcrun simctl status_bar "$device_id" override --time '9:41' --dataNetwork wifi --wifiMode active --wifiBars 3 --batteryState charged --batteryLevel 100
output="$artifact_root/raw/$language/$device_kind"
mkdir -p "$output"
pages=(home goals stats themes)
files=(01-today 02-goals 03-stats 04-themes)
for index in 0 1 2 3; do
  SIMCTL_CHILD_LAZYBUTNOT_SCREENSHOT_TAB="${pages[$index]}" \
    xcrun simctl launch --terminate-running-process "$device_id" "$app_id" \
      -selected_app_language "$app_language" -AppleLanguages "($language)" -AppleLocale "$app_locale"
  # Let SwiftUI finish its launch transition before capturing the simulator display.
  sleep 3
  xcrun simctl io "$device_id" screenshot "$output/${files[$index]}.png"
done
