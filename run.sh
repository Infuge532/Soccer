#!/bin/bash
# Builds Keeper and opens it in the iPhone simulator. You never have to open Xcode.
#
#   ./run.sh            build and launch on an iPhone simulator
#   ./run.sh -gallery 0 any extra words are passed to the app as launch arguments
#
# Xcode still has to be installed (free, Mac App Store), because it holds the
# iPhone build tools. This script handles its setup for you.

set -euo pipefail
cd "$(dirname "$0")"

say() { printf '\n\033[1;32m▸ %s\033[0m\n' "$1"; }
fail() { printf '\n\033[1;31m✗ %s\033[0m\n' "$1"; exit 1; }

# 1. Xcode must be installed and selected.
if [[ "$(xcode-select -p 2>/dev/null)" != *.app/Contents/Developer ]]; then
  if [ -d /Applications/Xcode.app ]; then
    say "Pointing the build tools at Xcode (asks for your Mac password once)"
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
  else
    fail "Install Xcode from the Mac App Store first (you won't need to open it), then run ./run.sh again."
  fi
fi

# 2. Finish Xcode's first-launch setup and license, without opening Xcode.
if ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
  say "Finishing Xcode setup (asks for your Mac password once)"
  sudo xcodebuild -license accept
  sudo xcodebuild -runFirstLaunch
fi

# 3. Find an iPhone simulator, downloading one if there are none.
find_iphone() {
  local list
  list=$(xcrun simctl list devices available | grep -E '^ +iPhone' | grep -v 'Duo' || true)
  { echo "$list" | grep 'Booted'; echo "$list"; } | grep -oE '[0-9A-F-]{36}' | head -1
}
UDID=${KEEPER_SIM:-$(find_iphone)}   # KEEPER_SIM=<udid> picks a specific simulator
if [ -z "$UDID" ]; then
  say "Downloading the iPhone simulator (one time, a few GB)"
  xcodebuild -downloadPlatform iOS
  UDID=$(find_iphone)
  [ -n "$UDID" ] || fail "No iPhone simulator found after the download. Try running ./run.sh again."
fi

# 4. Build. The simulator needs no Apple ID or signing team.
say "Building Keeper"
xcodebuild -project KeeperPlan.xcodeproj -scheme KeeperPlan -configuration Debug \
  -destination "id=$UDID" -derivedDataPath build/DerivedData \
  DEVELOPMENT_TEAM= CODE_SIGN_IDENTITY=- \
  -quiet build || fail "The build failed. Copy the error above and ask Claude to fix it."

APP=build/DerivedData/Build/Products/Debug-iphonesimulator/KeeperPlan.app

# 5. Open the simulator, install, launch.
say "Opening the iPhone simulator"
xcrun simctl boot "$UDID" 2>/dev/null || true
open -b com.apple.iphonesimulator 2>/dev/null \
  || open "$(xcode-select -p)/Applications/Simulator.app" 2>/dev/null \
  || echo "(Couldn't open the Simulator window. The app still runs; open Simulator from Spotlight to see it.)"
xcrun simctl bootstatus "$UDID" -b >/dev/null
xcrun simctl install "$UDID" "$APP"
xcrun simctl terminate "$UDID" app.keeperplan.hometraining 2>/dev/null || true
xcrun simctl launch "$UDID" app.keeperplan.hometraining "$@" >/dev/null
say "Keeper is running in the simulator"
