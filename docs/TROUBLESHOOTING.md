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

This is expected. TiltSwitch is configured with `LSUIElement=YES` and lives only in the menu bar.

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
