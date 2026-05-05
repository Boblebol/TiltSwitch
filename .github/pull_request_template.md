## Summary

- 

## Verification

- [ ] `xcodebuild test -project TiltSwitch.xcodeproj -scheme TiltSwitch -destination 'platform=macOS'`
- [ ] `xcodebuild build -project TiltSwitch.xcodeproj -scheme TiltSwitch -configuration Release`
- [ ] `plutil -lint TiltSwitch.xcodeproj/project.pbxproj TiltSwitch/Info.plist TiltSwitch/TiltSwitch.entitlements`

## Notes

Mention any changes to camera usage, Mission Control event posting, permissions, or lifecycle behavior.
