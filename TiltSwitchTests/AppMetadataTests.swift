import XCTest
@testable import TiltSwitch

final class AppMetadataTests: XCTestCase {
    func testPublicLinksPointToTiltSwitchPages() {
        XCTAssertEqual(AppMetadata.websiteURL.absoluteString, "https://boblebol.github.io/TiltSwitch/")
        XCTAssertEqual(AppMetadata.githubURL.absoluteString, "https://github.com/Boblebol/TiltSwitch")
    }

    func testSystemSettingsLinksUseSystemPreferencesScheme() {
        XCTAssertEqual(AppMetadata.cameraSettingsURL.scheme, "x-apple.systempreferences")
        XCTAssertEqual(AppMetadata.keyboardShortcutsSettingsURL.scheme, "x-apple.systempreferences")
    }
}
