# Architecture

TiltSwitch is a small AppKit menu bar app with strict boundaries between app lifecycle, camera processing, space switching, and HUD presentation.

## Runtime Flow

1. `AppDelegate` launches as a regular Dock app and creates the compact menu bar item.
2. The app loads `UserDefaults` settings for enabled state and sensitivity.
3. If enabled and unlocked, `AppDelegate` checks camera permission.
4. `HeadTiltMonitor` starts an `AVCaptureSession` on a dedicated background queue.
5. Camera frames are throttled to at most 15 Vision requests per second.
6. `VNDetectFaceLandmarksRequest` detects the first face and reads its roll angle.
7. Roll above the configured threshold emits `.right`; roll below the negative threshold emits `.left`.
8. `SpaceSwitcher` applies an 800ms cooldown and posts `Control` + arrow key events.
9. `HUDDisplayController` shows a floating SwiftUI arrow HUD for 600ms.

## Files

### `AppDelegate.swift`

Owns app lifecycle and AppKit integration:

- `NSStatusItem`
- Dock menu and app menu
- menu actions
- sensitivity settings
- diagnostics actions
- camera permission request
- screen lock/sleep handling
- transparent `NSPanel` creation
- wiring monitor events to switching and HUD display

### `HeadTiltMonitor.swift`

Owns camera and Vision work:

- `AVCaptureSession`
- `AVCaptureVideoDataOutput`
- background `DispatchQueue`
- 15fps Vision throttle
- `VNDetectFaceLandmarksRequest`
- direction emission from face roll

### `SpaceSwitcher.swift`

Owns space switching:

- `Direction`
- 800ms cooldown
- `CGEvent` creation
- `Control` + left/right arrow posting
- injected clock/event poster for unit tests

### `HUDView.swift`

Owns HUD presentation:

- SwiftUI SF Symbol arrow
- `200x60pt` fixed HUD content
- 600ms visibility timing
- 0.3s fade in/out
- top-center screen positioning

## Build Settings

- Minimum deployment: macOS 13.0
- Swift: 5.9
- Architectures: standard Universal macOS architectures
- App Sandbox: disabled
- Entitlements: camera only
- Dock icon: enabled
- Menu bar status item: enabled, compact square icon

## Performance Notes

Camera work stays off the main thread. Vision requests are capped at 15fps by dropping frames before request construction. The capture session is torn down and released whenever TiltSwitch is disabled, the screen locks, displays sleep, or the app quits.
