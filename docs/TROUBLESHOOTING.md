# Troubleshooting

## Camera Permission Was Denied

Open:

```text
System Settings > Privacy & Security > Camera
```

Enable camera access for TiltSwitch, then relaunch the app.

## Spaces Do Not Switch

Check Mission Control keyboard shortcuts:

```text
System Settings > Keyboard > Keyboard Shortcuts > Mission Control
```

Enable shortcuts for moving left and right a space. TiltSwitch posts `Control` + `Left Arrow` and `Control` + `Right Arrow`.

## The App Does Not Show In The Dock

Current builds show a Dock icon and a menu bar item. If you installed an older build, download the latest release and replace the app in `/Applications`.

## The Dock Icon Shows But The Menu Bar Item Does Not

TiltSwitch `0.1.10` and newer open a floating control panel at launch and also show a plain `TiltSwitch` item in the top-right menu bar, near Control Center. If you do not see the menu bar item:

1. Quit TiltSwitch from the Dock menu.
2. Replace `/Applications/TiltSwitch.app` with the latest release.
3. Relaunch the app.
4. Use the floating panel first, then look for `TiltSwitch` near Wi-Fi, battery, clock, or Control Center.

On notched MacBooks or crowded menu bars, macOS may hide extra status items. The floating panel stays available from the Dock icon even when that happens.

## How To Verify The App Is Working

Use the floating control panel, the TiltSwitch menu bar item, or right-click the Dock icon:

1. Click `Check` in the panel or open `Diagnostics > Run Self Check`.
2. Confirm camera permission is OK.
3. Click `Left` and `Right` to verify the overlay.
4. Use `Diagnostics > Test Previous Space` and `Test Next Space` to verify Mission Control keyboard events.

If the HUD tests work but space tests do not, enable Mission Control shortcuts for `Control` + Left/Right Arrow in System Settings.

## CPU Usage Is High

TiltSwitch should throttle Vision work to 15fps. If CPU usage is unexpectedly high:

- verify the app is not running multiple copies
- disable and re-enable the app from the menu bar
- check that `HeadTiltMonitor.minimumVisionInterval` remains `1.0 / 15.0`

## Command Line Build Fails With Xcode-Select

If `xcodebuild` reports that Command Line Tools are selected, switch to a full Xcode install:

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```
