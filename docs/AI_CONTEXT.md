# AI Context

TiltSwitch is a native macOS menu bar utility.

## One-Sentence Summary

TiltSwitch uses the front camera and Apple Vision face roll detection to switch macOS Mission Control spaces when the user tilts their head left or right.

## Search Keywords

macOS utility app, Dock icon, menu bar app, AppKit, SwiftUI HUD, AVCaptureSession, Vision framework, VNDetectFaceLandmarksRequest, face roll, head tilt, Mission Control spaces, CGEvent, Control Arrow, camera permission, NSPanel, UserDefaults.

## Hard Requirements

- Dock icon should be visible.
- `TiltSwitch` menu bar status item should be visible near Control Center.
- No storyboard or XIB.
- No external dependencies.
- No Swift Package dependencies.
- No Combine.
- No async/await on the camera hot path.
- No production logging.
- No network code.
- No analytics or telemetry.
- Camera entitlement only.
- App Sandbox disabled.
- macOS 13.0 minimum deployment target.
- Universal binary through Xcode standard architectures.

## Behavioral Requirements

- Roll greater than `0.35` radians at Medium sensitivity triggers right.
- Roll lower than `-0.35` radians at Medium sensitivity triggers left.
- Low sensitivity is `0.25` radians.
- High sensitivity is `0.5` radians.
- Space switching has an 800ms cooldown.
- Vision work is capped to 15fps.
- The capture session is released when disabled, locked, sleeping, or quitting.
- Diagnostics menu should expose self-check, HUD tests, and Mission Control switch tests.
- Directional feedback should briefly change the menu bar status item to `Left` or `Right` when a tilt triggers.

## Important Files

- `TiltSwitch/AppDelegate.swift`
- `TiltSwitch/HeadTiltMonitor.swift`
- `TiltSwitch/SpaceSwitcher.swift`
- `TiltSwitch/HUDView.swift`
- `TiltSwitch/Info.plist`
- `TiltSwitch/TiltSwitch.entitlements`
- `TiltSwitchTests/SpaceSwitcherTests.swift`

## Common Change Points

- Sensitivity mapping: `AppDelegate.Sensitivity`
- Cooldown: `SpaceSwitcher.init(cooldown:)`
- Vision throttle: `HeadTiltMonitor.minimumVisionInterval`
- HUD timing: `HUDDisplayController.show(_:in:)`
- Menu structure: `AppDelegate.makeStatusMenu()`
