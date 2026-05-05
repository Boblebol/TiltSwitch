import CoreGraphics
import Foundation

enum Direction: Equatable {
    case left
    case right

    var symbolName: String {
        switch self {
        case .left:
            return "arrow.left"
        case .right:
            return "arrow.right"
        }
    }

    fileprivate var keyCode: CGKeyCode {
        switch self {
        case .left:
            return 0x7B
        case .right:
            return 0x7C
        }
    }
}

final class SpaceSwitcher {
    typealias EventPoster = (Direction) -> Void
    typealias Clock = () -> TimeInterval

    private let cooldown: TimeInterval
    private let now: Clock
    private let eventPoster: EventPoster
    private var lastSwitchTime: TimeInterval?

    init(
        cooldown: TimeInterval = 0.8,
        now: @escaping Clock = { Date.timeIntervalSinceReferenceDate },
        eventPoster: @escaping EventPoster = SpaceSwitcher.postControlArrow
    ) {
        self.cooldown = cooldown
        self.now = now
        self.eventPoster = eventPoster
    }

    @discardableResult
    func switchSpace(_ direction: Direction) -> Bool {
        let currentTime = now()
        if let lastSwitchTime, currentTime - lastSwitchTime < cooldown {
            return false
        }

        lastSwitchTime = currentTime
        eventPoster(direction)
        return true
    }

    private static func postControlArrow(_ direction: Direction) {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: direction.keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: direction.keyCode, keyDown: false)

        keyDown?.flags = .maskControl
        keyUp?.flags = .maskControl
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
