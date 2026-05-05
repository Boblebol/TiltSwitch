# Testing

TiltSwitch has unit coverage for the pure space-switching cooldown logic.

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

## Manual Checks

Manual app checks require camera permission and Mission Control shortcuts:

1. Launch TiltSwitch.
2. Grant camera permission.
3. Confirm the `Tilt` menu bar item appears near Control Center.
4. Run `Diagnostics > Test HUD Left` and `Test HUD Right`; the menu bar item should briefly change to `Left` or `Right`.
5. Select Medium sensitivity.
6. Tilt right and verify the next Mission Control space is selected.
7. Tilt left and verify the previous Mission Control space is selected.
8. Disable TiltSwitch and verify camera capture stops.
9. Lock the screen and unlock it; verify capture resumes only if the app is enabled.
