# Release Process

TiltSwitch is distributed as a standard macOS app build from Xcode.

## Pre-Release Checklist

Run:

```sh
xcodebuild test -project TiltSwitch.xcodeproj -scheme TiltSwitch -destination 'platform=macOS'
xcodebuild build -project TiltSwitch.xcodeproj -scheme TiltSwitch -configuration Release
plutil -lint TiltSwitch.xcodeproj/project.pbxproj TiltSwitch/Info.plist TiltSwitch/TiltSwitch.entitlements
xmllint --noout TiltSwitch.xcodeproj/xcshareddata/xcschemes/TiltSwitch.xcscheme
```

Then verify:

- The Dock icon is visible.
- The floating control panel opens and its buttons are clickable.
- The `TiltSwitch` menu bar status item is visible near Control Center.
- `Info.plist` contains `NSCameraUsageDescription`.
- `TiltSwitch.entitlements` contains camera access only.
- App Sandbox is not enabled in the project.
- Release build targets macOS 13.0 or newer.
- Release build uses standard Universal macOS architectures.

## Versioning

Update:

- `CHANGELOG.md`
- `MARKETING_VERSION`
- `CURRENT_PROJECT_VERSION`

## GitHub Release

Create a tag:

```sh
git tag vX.Y.Z
git push origin vX.Y.Z
```

The `Package App` workflow builds and uploads:

- `TiltSwitch-vX.Y.Z-macOS.dmg`
- `TiltSwitch-vX.Y.Z-macOS.zip`
- `checksums.txt`

The workflow can also be run manually from GitHub Actions with a release tag input.
