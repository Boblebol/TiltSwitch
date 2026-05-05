# Changelog

All notable changes to TiltSwitch will be documented in this file.

## 0.1.9 - 2026-05-05

- Removed status item position autosaving so macOS cannot restore a hidden or stale menu bar placement.
- Changed the menu bar item to plain `TiltSwitch` text for maximum visibility.

## 0.1.8 - 2026-05-05

- Changed the menu bar item from icon-only to a visible `Tilt` label with a directional icon.
- Directional feedback now briefly changes the label to `Left` or `Right`.

## 0.1.7 - 2026-05-05

- Added menu bar feedback when a left or right head tilt is detected.
- Moved directional UI feedback onto the main thread before updating AppKit views.

## 0.1.6 - 2026-05-05

- Fixed release entitlement export so package validation reads the signed app entitlements as XML.

## 0.1.5 - 2026-05-05

- Disabled Xcode base entitlement injection for release packaging.
- Added package-time entitlement validation so the distributed app contains only camera access.

## 0.1.4 - 2026-05-05

- Fixed the Universal architecture validation script so it accepts `lipo` output in either architecture order.

## 0.1.3 - 2026-05-05

- Forced release packaging to build a Universal `arm64` + `x86_64` binary.
- Added package-time architecture validation so non-Universal releases fail before upload.
- Made the package workflow create the GitHub Release automatically when a new version tag is pushed.

## 0.1.2 - 2026-05-05

- Changed the menu bar item to a compact square walking icon so it stays visible on crowded or notched menu bars.
- Added clearer troubleshooting docs for the case where the Dock icon appears but the menu bar icon is hard to find.
- Updated release/package defaults to `0.1.2`.

## 0.1.1 - 2026-05-05

- Added visible Dock icon and custom app icon.
- Added richer menu bar, Dock menu, website/GitHub/settings links, and diagnostics.
- Added self-check, HUD test, and Mission Control switch test menu items.
- Updated docs for manual verification and troubleshooting.

## 0.1.0 - 2026-05-05

- Initial macOS menu bar app scaffold.
- Added camera-based head roll detection with Vision.
- Added Mission Control space switching with `Control` + arrow keys.
- Added sensitivity presets, HUD feedback, screen lock handling, and settings persistence.
- Added GitHub Pages landing page and packaged release artifacts.
