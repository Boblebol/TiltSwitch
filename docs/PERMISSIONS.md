# Permissions

TiltSwitch uses two macOS capabilities:

## Camera

TiltSwitch requests camera access to detect head roll with Apple Vision. The camera entitlement is:

```xml
<key>com.apple.security.device.camera</key>
<true/>
```

The `Info.plist` camera usage text is:

```text
TiltSwitch uses the camera to detect head tilt. No video is recorded or transmitted.
```

Camera frames are processed locally and are not stored.

## Synthetic Keyboard Events

TiltSwitch posts `Control` + arrow key events with `CGEvent`:

- `Control` + `Left Arrow`
- `Control` + `Right Arrow`

These shortcuts are used by Mission Control to move between spaces.

## Sandbox

The App Sandbox is intentionally disabled. Sandboxing would interfere with the low-level event posting needed for Mission Control space switching.

No other entitlements should be added unless the app behavior changes.
