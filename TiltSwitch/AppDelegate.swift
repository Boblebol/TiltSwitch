import AppKit
import SwiftUI

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private enum DefaultsKey {
        static let isEnabled = "isEnabled"
        static let sensitivity = "sensitivity"
    }

    private enum Sensitivity: String, CaseIterable {
        case low
        case medium
        case high

        var title: String {
            switch self {
            case .low:
                return "Low"
            case .medium:
                return "Medium"
            case .high:
                return "High"
            }
        }

        var threshold: Double {
            switch self {
            case .low:
                return 0.25
            case .medium:
                return 0.35
            case .high:
                return 0.5
            }
        }
    }

    private let defaults = UserDefaults.standard
    private let hudDisplayController = HUDDisplayController()
    private let monitor = HeadTiltMonitor()
    private let spaceSwitcher = SpaceSwitcher()

    private var statusItem: NSStatusItem?
    private var hudPanel: NSPanel?
    private var isEnabled = true
    private var sensitivity: Sensitivity = .medium
    private var isScreenLocked = false
    private var permissionAlertVisible = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        guard !isRunningUnitTests else {
            return
        }

        loadSettings()
        setupStatusItem()
        setupHUDPanel()
        registerScreenStateNotifications()

        monitor.onDirection = { [weak self] direction in
            self?.handle(direction)
        }

        updateMonitorState()
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor.stop()
        DistributedNotificationCenter.default().removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    private func loadSettings() {
        if defaults.object(forKey: DefaultsKey.isEnabled) == nil {
            defaults.set(true, forKey: DefaultsKey.isEnabled)
        }
        isEnabled = defaults.bool(forKey: DefaultsKey.isEnabled)

        if
            let rawSensitivity = defaults.string(forKey: DefaultsKey.sensitivity),
            let storedSensitivity = Sensitivity(rawValue: rawSensitivity)
        {
            sensitivity = storedSensitivity
        } else {
            sensitivity = .medium
            defaults.set(sensitivity.rawValue, forKey: DefaultsKey.sensitivity)
        }
    }

    private var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            || NSClassFromString("XCTestCase") != nil
    }

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(
            systemSymbolName: "figure.walk",
            accessibilityDescription: "TiltSwitch"
        )
        item.menu = makeMenu()
        statusItem = item
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()

        let enabledItem = NSMenuItem(
            title: "Enable TiltSwitch",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        enabledItem.target = self
        enabledItem.state = isEnabled ? .on : .off
        menu.addItem(enabledItem)

        let sensitivityItem = NSMenuItem(title: "Sensitivity", action: nil, keyEquivalent: "")
        let sensitivityMenu = NSMenu()
        for value in Sensitivity.allCases {
            let item = NSMenuItem(
                title: value.title,
                action: #selector(selectSensitivity),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = value.rawValue
            item.state = value == sensitivity ? .on : .off
            sensitivityMenu.addItem(item)
        }
        sensitivityItem.submenu = sensitivityMenu
        menu.addItem(sensitivityItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func setupHUDPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 60),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.backgroundColor = .clear
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: HUDView(symbolName: "arrow.right"))
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.isOpaque = false
        panel.level = .floating
        panel.alphaValue = 0
        hudPanel = panel
    }

    private func registerScreenStateNotifications() {
        let distributedCenter = DistributedNotificationCenter.default()
        distributedCenter.addObserver(
            self,
            selector: #selector(screenDidLock),
            name: Notification.Name("com.apple.screenIsLocked"),
            object: nil
        )
        distributedCenter.addObserver(
            self,
            selector: #selector(screenDidUnlock),
            name: Notification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )

        let workspaceCenter = NSWorkspace.shared.notificationCenter
        workspaceCenter.addObserver(
            self,
            selector: #selector(screenDidSleep),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
        workspaceCenter.addObserver(
            self,
            selector: #selector(screenDidWake),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )
    }

    private func updateMonitorState() {
        guard isEnabled, !isScreenLocked else {
            monitor.stop()
            return
        }

        switch HeadTiltMonitor.cameraPermission() {
        case .authorized:
            monitor.start(sensitivityThreshold: sensitivity.threshold)
        case .notDetermined:
            HeadTiltMonitor.requestCameraPermission { [weak self] granted in
                guard let self else {
                    return
                }
                if granted {
                    self.monitor.start(sensitivityThreshold: self.sensitivity.threshold)
                } else {
                    self.monitor.stop()
                    self.showCameraDeniedAlert()
                }
            }
        case .denied:
            monitor.stop()
            showCameraDeniedAlert()
        }
    }

    private func updateMenu() {
        statusItem?.menu = makeMenu()
    }

    private func handle(_ direction: Direction) {
        guard isEnabled, !isScreenLocked else {
            return
        }

        guard spaceSwitcher.switchSpace(direction) else {
            return
        }

        guard let panel = hudPanel else {
            return
        }

        hudDisplayController.show(direction, in: panel)
    }

    private func showCameraDeniedAlert() {
        guard !permissionAlertVisible else {
            return
        }

        permissionAlertVisible = true
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Camera Access Needed"
        alert.informativeText = "TiltSwitch uses the camera to detect head tilt. No video is recorded or transmitted."
        alert.addButton(withTitle: "OK")
        alert.runModal()

        permissionAlertVisible = false
    }

    @objc private func toggleEnabled() {
        isEnabled.toggle()
        defaults.set(isEnabled, forKey: DefaultsKey.isEnabled)
        updateMenu()
        updateMonitorState()
    }

    @objc private func selectSensitivity(_ sender: NSMenuItem) {
        guard
            let rawValue = sender.representedObject as? String,
            let selectedSensitivity = Sensitivity(rawValue: rawValue)
        else {
            return
        }

        sensitivity = selectedSensitivity
        defaults.set(sensitivity.rawValue, forKey: DefaultsKey.sensitivity)
        monitor.updateSensitivityThreshold(sensitivity.threshold)
        updateMenu()
    }

    @objc private func screenDidLock() {
        isScreenLocked = true
        monitor.stop()
    }

    @objc private func screenDidUnlock() {
        isScreenLocked = false
        updateMonitorState()
    }

    @objc private func screenDidSleep() {
        isScreenLocked = true
        monitor.stop()
    }

    @objc private func screenDidWake() {
        isScreenLocked = false
        updateMonitorState()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
