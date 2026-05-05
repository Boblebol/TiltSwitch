# TiltSwitch

[![CI](https://github.com/Boblebol/TiltSwitch/actions/workflows/ci.yml/badge.svg)](https://github.com/Boblebol/TiltSwitch/actions/workflows/ci.yml)
[![Package App](https://github.com/Boblebol/TiltSwitch/actions/workflows/package.yml/badge.svg)](https://github.com/Boblebol/TiltSwitch/actions/workflows/package.yml)

TiltSwitch is a lightweight macOS menu bar app that uses the front camera and Apple Vision to detect head roll. Tilting your head switches Mission Control spaces:

- Tilt right: `Control` + `Right Arrow`
- Tilt left: `Control` + `Left Arrow`

It is built with pure Apple frameworks, no third-party dependencies, and a programmatic AppKit entry point.

## Features

- Dock icon plus compact menu bar status item
- Real-time head roll detection with `AVCaptureSession` and `VNDetectFaceLandmarksRequest`
- Mission Control space switching through `CGEvent`
- 800ms cooldown to avoid repeated space switches
- Sensitivity presets:
  - Low: `0.25` radians
  - Medium: `0.35` radians
  - High: `0.5` radians
- Transparent floating HUD with left/right SF Symbols
- Diagnostics menu for self-checks, HUD tests, and Mission Control switch tests
- Camera starts only while TiltSwitch is enabled
- Camera session is released when disabled, sleeping, locked, or quitting
- No network calls, telemetry, analytics, storyboard, XIB, packages, or external dependencies

## Requirements

- macOS 13.0 or newer
- Xcode with macOS SDK
- Front-facing camera
- Mission Control keyboard shortcuts enabled for `Control` + arrow keys

## Download

The latest packaged build is available from [GitHub Releases](https://github.com/Boblebol/TiltSwitch/releases/latest):

- `TiltSwitch-vX.Y.Z-macOS.dmg` - drag-and-drop installer
- `TiltSwitch-vX.Y.Z-macOS.zip` - zipped app bundle
- `checksums.txt` - SHA-256 checksums

Early builds are not notarized. If macOS blocks first launch, right-click `TiltSwitch.app`, choose Open, then confirm.

Website: https://boblebol.github.io/TiltSwitch/

## Debug And Verify

After launching TiltSwitch, use the Dock icon or the compact walking icon in the top-right menu bar, near Control Center:

1. Open `Diagnostics > Run Self Check`.
2. Confirm camera permission is OK.
3. Run `Diagnostics > Test HUD Left` and `Test HUD Right`.
4. Run `Diagnostics > Test Previous Space` and `Test Next Space`.
5. If space switching does not move, open `Mission Control Shortcuts` and enable `Control` + Left/Right Arrow.

The app also has quick links to the website, GitHub, Camera Settings, and Quit.

If you see the Dock icon but not the menu bar icon, make sure you are running `0.1.2` or newer. Older builds used a wider status item that macOS could hide when the menu bar was crowded.

## Build

Open `TiltSwitch.xcodeproj` in Xcode and build the `TiltSwitch` scheme.

Command line:

```sh
xcodebuild build \
  -project TiltSwitch.xcodeproj \
  -scheme TiltSwitch \
  -configuration Release
```

Run tests:

```sh
xcodebuild test \
  -project TiltSwitch.xcodeproj \
  -scheme TiltSwitch \
  -destination 'platform=macOS'
```

For CI or unsigned local builds, pass `CODE_SIGNING_ALLOWED=NO`.

## Permissions

TiltSwitch requests camera permission on first launch. The camera usage description is:

> TiltSwitch uses the camera to detect head tilt. No video is recorded or transmitted.

The app uses the camera frames locally only for Vision face roll detection.

## Architecture

TiltSwitch intentionally keeps one file per concern:

- `AppDelegate.swift` - status item, menu, settings, permission flow, HUD panel, lifecycle
- `HeadTiltMonitor.swift` - camera capture, Vision face landmarks, 15fps frame throttling
- `SpaceSwitcher.swift` - `CGEvent` posting and cooldown logic
- `HUDView.swift` - SwiftUI arrow overlay and fade timing

More details are in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Building](docs/BUILDING.md)
- [Testing](docs/TESTING.md)
- [Permissions](docs/PERMISSIONS.md)
- [Privacy](docs/PRIVACY.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Release Process](docs/RELEASE.md)
- [AI Context](docs/AI_CONTEXT.md)

## Privacy

TiltSwitch does not record, store, transmit, upload, log, or analyze video outside the local process. See [docs/PRIVACY.md](docs/PRIVACY.md).

## Repository Map

AI agents and contributors should start with [AGENTS.md](AGENTS.md) and [docs/AI_CONTEXT.md](docs/AI_CONTEXT.md). These files summarize the project constraints, architecture, and verification commands.

## License

MIT. See [LICENSE](LICENSE).
