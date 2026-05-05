import XCTest
@testable import TiltSwitch

final class ControlPanelModelTests: XCTestCase {
    func testMenuBarStatusReportsAttachedWhenButtonHasAWindow() {
        XCTAssertEqual(
            ControlPanelModel.menuBarStatus(
                itemExists: true,
                itemIsVisible: true,
                buttonHasWindow: true
            ),
            "Menu bar: attached"
        )
    }

    func testMenuBarStatusReportsHiddenWhenButtonHasNoWindow() {
        XCTAssertEqual(
            ControlPanelModel.menuBarStatus(
                itemExists: true,
                itemIsVisible: true,
                buttonHasWindow: false
            ),
            "Menu bar: created, hidden by macOS"
        )
    }

    func testStatusCopyFollowsEnabledState() {
        let enabled = ControlPanelModel(
            isEnabled: true,
            sensitivityTitle: "Medium",
            thresholdText: "0.35 rad",
            cameraStatus: "Camera: OK",
            screenStatus: "Screen: active",
            menuBarStatus: "Menu bar: attached",
            versionText: "0.1.10",
            sensitivityOptions: []
        )
        let paused = ControlPanelModel(
            isEnabled: false,
            sensitivityTitle: "Medium",
            thresholdText: "0.35 rad",
            cameraStatus: "Camera: OK",
            screenStatus: "Screen: active",
            menuBarStatus: "Menu bar: attached",
            versionText: "0.1.10",
            sensitivityOptions: []
        )

        XCTAssertEqual(enabled.statusTitle, "Enabled")
        XCTAssertEqual(paused.statusTitle, "Paused")
    }
}
