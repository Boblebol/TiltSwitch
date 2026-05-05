# Contributing

Thanks for improving TiltSwitch.

## Local Setup

1. Install Xcode.
2. Open `TiltSwitch.xcodeproj`.
3. Build the `TiltSwitch` scheme.

## Development Rules

- Keep the app pure Swift/AppKit/SwiftUI/AVFoundation/Vision/CoreGraphics.
- Do not add third-party dependencies or Swift Package dependencies.
- Do not add network calls, analytics, telemetry, storyboard, or XIB files.
- Keep camera processing off the main thread.
- Keep Vision throttled to 15fps or lower.
- Release the camera session when the app is disabled, locked, sleeping, or quitting.

## Checks

```sh
xcodebuild test -project TiltSwitch.xcodeproj -scheme TiltSwitch -destination 'platform=macOS'
xcodebuild build -project TiltSwitch.xcodeproj -scheme TiltSwitch -configuration Release
plutil -lint TiltSwitch.xcodeproj/project.pbxproj TiltSwitch/Info.plist TiltSwitch/TiltSwitch.entitlements
xmllint --noout TiltSwitch.xcodeproj/xcshareddata/xcschemes/TiltSwitch.xcscheme
```

Use `CODE_SIGNING_ALLOWED=NO` when building in CI or on machines without signing identities.
