# Privacy

TiltSwitch uses the camera only to detect head roll angle locally.

## What TiltSwitch Does

- Requests camera permission through macOS.
- Reads camera frames inside the local app process.
- Runs Apple Vision face landmark detection locally.
- Uses the detected face roll angle to decide whether to switch spaces.

## What TiltSwitch Does Not Do

- No video recording.
- No screenshots.
- No audio capture.
- No network requests.
- No telemetry.
- No analytics.
- No upload or transmission of camera frames.
- No persistent storage of images or video.

## Stored Data

TiltSwitch stores only local settings in `UserDefaults`:

- whether the app is enabled
- selected sensitivity preset

## Camera Lifecycle

The camera session runs only while TiltSwitch is enabled and the screen is active. The session is stopped and released when:

- TiltSwitch is disabled from the menu bar
- the screen locks
- displays sleep
- the app quits
