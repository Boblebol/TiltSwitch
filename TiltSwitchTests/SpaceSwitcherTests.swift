import XCTest
@testable import TiltSwitch

final class SpaceSwitcherTests: XCTestCase {
    func testPostsRightDirectionWhenCooldownAllows() {
        var now: TimeInterval = 10
        var postedDirections: [Direction] = []
        let switcher = SpaceSwitcher(
            cooldown: 0.8,
            now: { now },
            eventPoster: { postedDirections.append($0) }
        )

        let didSwitch = switcher.switchSpace(.right)

        XCTAssertTrue(didSwitch)
        XCTAssertEqual(postedDirections, [.right])
    }

    func testPostsLeftDirectionWhenCooldownAllows() {
        var now: TimeInterval = 10
        var postedDirections: [Direction] = []
        let switcher = SpaceSwitcher(
            cooldown: 0.8,
            now: { now },
            eventPoster: { postedDirections.append($0) }
        )

        let didSwitch = switcher.switchSpace(.left)

        XCTAssertTrue(didSwitch)
        XCTAssertEqual(postedDirections, [.left])
    }

    func testSuppressesSwitchesDuringCooldown() {
        var now: TimeInterval = 10
        var postedDirections: [Direction] = []
        let switcher = SpaceSwitcher(
            cooldown: 0.8,
            now: { now },
            eventPoster: { postedDirections.append($0) }
        )

        XCTAssertTrue(switcher.switchSpace(.right))
        now = 10.7
        XCTAssertFalse(switcher.switchSpace(.left))

        XCTAssertEqual(postedDirections, [.right])
    }

    func testAllowsSwitchAfterCooldown() {
        var now: TimeInterval = 10
        var postedDirections: [Direction] = []
        let switcher = SpaceSwitcher(
            cooldown: 0.8,
            now: { now },
            eventPoster: { postedDirections.append($0) }
        )

        XCTAssertTrue(switcher.switchSpace(.right))
        now = 10.8
        XCTAssertTrue(switcher.switchSpace(.left))

        XCTAssertEqual(postedDirections, [.right, .left])
    }
}
