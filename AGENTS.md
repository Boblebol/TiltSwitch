# Agent Guide

This repository contains TiltSwitch, a small native macOS menu bar app written in Swift.

## Project Constraints

- Keep the app dependency-free: Apple frameworks only.
- Keep one source file per concern:
  - `AppDelegate.swift`: AppKit app lifecycle, status item, menu, settings, permission flow, panels.
  - `ControlPanelView.swift`: SwiftUI floating controls and status diagnostics.
  - `HeadTiltMonitor.swift`: camera capture and Vision face roll detection.
  - `SpaceSwitcher.swift`: Mission Control space switching and cooldown.
  - `HUDView.swift`: SwiftUI HUD overlay.
- Do not add storyboard, XIB, Swift Package dependencies, Combine, network calls, analytics, or telemetry.
- Minimum deployment target is macOS 13.0.
- Build must remain Universal (`arm64` and `x86_64`).
- App Sandbox must remain disabled. The only entitlement should be camera access.
- `Info.plist` must not set `LSUIElement`; the app should show a Dock icon and a menu bar item.

## Verification

Use a full Xcode installation for the canonical checks:

```sh
xcodebuild test -project TiltSwitch.xcodeproj -scheme TiltSwitch -destination 'platform=macOS'
xcodebuild build -project TiltSwitch.xcodeproj -scheme TiltSwitch -configuration Release
```

When running in CI or without signing identities:

```sh
xcodebuild test -project TiltSwitch.xcodeproj -scheme TiltSwitch -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
xcodebuild build -project TiltSwitch.xcodeproj -scheme TiltSwitch -configuration Release CODE_SIGNING_ALLOWED=NO
```

Useful lightweight checks:

```sh
plutil -lint TiltSwitch.xcodeproj/project.pbxproj TiltSwitch/Info.plist TiltSwitch/TiltSwitch.entitlements
xmllint --noout TiltSwitch.xcodeproj/xcshareddata/xcschemes/TiltSwitch.xcscheme
```
