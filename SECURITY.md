# Security Policy

## Supported Versions

TiltSwitch is early-stage software. Security fixes target the latest version on `main`.

## Reporting A Vulnerability

Please open a private security advisory on GitHub or contact the repository owner directly.

Do not publish exploit details before a fix is available.

## Security Model

TiltSwitch is a local-only macOS app. It uses:

- Camera access for local Vision face roll detection.
- Synthetic keyboard events for Mission Control space switching.
- `UserDefaults` for local settings.

TiltSwitch does not include network code, analytics, telemetry, remote configuration, account systems, or persistent video storage.
