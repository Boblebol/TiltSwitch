# Building TiltSwitch

## Requirements

- macOS 13.0 or newer
- Xcode with macOS SDK
- Swift 5.9-compatible project settings

## Xcode

Open:

```sh
open TiltSwitch.xcodeproj
```

Build the `TiltSwitch` scheme.

## Command Line Build

```sh
xcodebuild build \
  -project TiltSwitch.xcodeproj \
  -scheme TiltSwitch \
  -configuration Release
```

## Package A Release Locally

With a full Xcode installation selected:

```sh
bash scripts/package-release.sh 0.1.8
```

This creates:

- `dist/TiltSwitch-v0.1.8-macOS.dmg`
- `dist/TiltSwitch-v0.1.8-macOS.zip`
- `dist/checksums.txt`

If code signing is not configured:

```sh
xcodebuild build \
  -project TiltSwitch.xcodeproj \
  -scheme TiltSwitch \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO
```

## Tests

```sh
xcodebuild test \
  -project TiltSwitch.xcodeproj \
  -scheme TiltSwitch \
  -destination 'platform=macOS'
```

Without signing:

```sh
xcodebuild test \
  -project TiltSwitch.xcodeproj \
  -scheme TiltSwitch \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO
```

## Lightweight Validation

```sh
plutil -lint TiltSwitch.xcodeproj/project.pbxproj TiltSwitch/Info.plist TiltSwitch/TiltSwitch.entitlements
xmllint --noout TiltSwitch.xcodeproj/xcshareddata/xcschemes/TiltSwitch.xcscheme
```
