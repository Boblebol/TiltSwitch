# Testing

TiltSwitch has unit coverage for the pure space-switching cooldown logic and floating control panel status copy.

## Run Tests

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

## Covered Behavior

`TiltSwitchTests/SpaceSwitcherTests.swift` verifies:

- right direction posts when cooldown allows
- left direction posts when cooldown allows
- switches inside the 800ms cooldown are suppressed
- switches after the cooldown are allowed

`TiltSwitchTests/ControlPanelModelTests.swift` verifies:

- menu bar diagnostic text for attached status items
- menu bar diagnostic text when macOS hides a created status item
- enabled/paused status copy

## Manual Checks

Manual app checks require camera permission and Mission Control shortcuts:

1. Launch TiltSwitch.
2. Grant camera permission.
3. Confirm the floating control panel appears.
4. Confirm the `TiltSwitch` menu bar item appears near Control Center when macOS has room for it.
5. Click `Left` and `Right` in the panel; the HUD should appear and the menu bar item should briefly change to `Left` or `Right` if visible.
6. Select Medium sensitivity.
7. Tilt right and verify the next Mission Control space is selected.
8. Tilt left and verify the previous Mission Control space is selected.
9. Disable TiltSwitch and verify camera capture stops.
10. Lock the screen and unlock it; verify capture resumes only if the app is enabled.
