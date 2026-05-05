#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-0.1.4}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
APP_PATH="$DERIVED_DATA_DIR/Build/Products/Release/TiltSwitch.app"
DIST_DIR="$ROOT_DIR/dist"
DMG_ROOT="$DIST_DIR/dmg-root"
ZIP_PATH="$DIST_DIR/TiltSwitch-v${VERSION}-macOS.zip"
DMG_PATH="$DIST_DIR/TiltSwitch-v${VERSION}-macOS.dmg"

rm -rf "$DIST_DIR" "$BUILD_DIR"
mkdir -p "$DIST_DIR" "$DMG_ROOT"

xcodebuild build \
  -project "$ROOT_DIR/TiltSwitch.xcodeproj" \
  -scheme TiltSwitch \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGNING_ALLOWED=YES \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="-"

codesign --verify --deep --strict "$APP_PATH"

ARCH_OUTPUT="$(lipo -archs "$APP_PATH/Contents/MacOS/TiltSwitch")"
if [[ " $ARCH_OUTPUT " != *" arm64 "* || " $ARCH_OUTPUT " != *" x86_64 "* ]]; then
  printf 'Expected Universal binary with arm64 and x86_64, got: %s\n' "$ARCH_OUTPUT" >&2
  exit 1
fi

ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

ditto "$APP_PATH" "$DMG_ROOT/TiltSwitch.app"
ln -s /Applications "$DMG_ROOT/Applications"
hdiutil create \
  -volname TiltSwitch \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

shasum -a 256 "$ZIP_PATH" "$DMG_PATH" > "$DIST_DIR/checksums.txt"

printf '%s\n' "$ZIP_PATH"
printf '%s\n' "$DMG_PATH"
printf '%s\n' "$DIST_DIR/checksums.txt"
