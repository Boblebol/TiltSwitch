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
        NSApp.setActivationPolicy(.regular)
        guard !isRunningUnitTests else {
            return
        }

        loadSettings()
        setupMainMenu()
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
        let image = NSImage(
            systemSymbolName: "figure.walk",
            accessibilityDescription: "TiltSwitch"
        )
        image?.isTemplate = true
        item.button?.image = image
        item.button?.title = " \(AppMetadata.statusItemTitle)"
        item.button?.imagePosition = .imageLeft
        item.menu = makeStatusMenu()
        statusItem = item
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu(title: AppMetadata.displayName)

        appMenu.addItem(makeMenuItem(
            title: "About TiltSwitch",
            action: #selector(showAbout),
            systemSymbolName: "info.circle"
        ))
        appMenu.addItem(.separator())
        appMenu.addItem(makeMenuItem(
            title: "Open Website",
            action: #selector(openWebsite),
            systemSymbolName: "safari"
        ))
        appMenu.addItem(makeMenuItem(
            title: "View on GitHub",
            action: #selector(openGitHub),
            systemSymbolName: "chevron.left.forwardslash.chevron.right"
        ))
        appMenu.addItem(.separator())
        appMenu.addItem(makeMenuItem(
            title: "Quit TiltSwitch",
            action: #selector(quit),
            keyEquivalent: "q",
            systemSymbolName: "power"
        ))

        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu
    }

    private func makeStatusMenu() -> NSMenu {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "TiltSwitch", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        titleItem.image = NSApp.applicationIconImage
        menu.addItem(titleItem)

        let stateTitle = isEnabled ? "Active" : "Paused"
        let stateItem = NSMenuItem(
            title: "\(stateTitle) · \(sensitivity.title) sensitivity",
            action: nil,
            keyEquivalent: ""
        )
        stateItem.isEnabled = false
        menu.addItem(stateItem)
        menu.addItem(.separator())

        let enabledItem = NSMenuItem(
            title: isEnabled ? "Disable TiltSwitch" : "Enable TiltSwitch",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        )
        enabledItem.target = self
        enabledItem.state = isEnabled ? .on : .off
        enabledItem.image = NSImage(systemSymbolName: isEnabled ? "pause.circle" : "play.circle", accessibilityDescription: nil)
        menu.addItem(enabledItem)

        let sensitivityItem = NSMenuItem(title: "Sensitivity", action: nil, keyEquivalent: "")
        sensitivityItem.image = NSImage(systemSymbolName: "slider.horizontal.3", accessibilityDescription: nil)
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
        menu.addItem(makeMenuItem(
            title: "Open Website",
            action: #selector(openWebsite),
            systemSymbolName: "safari"
        ))
        menu.addItem(makeMenuItem(
            title: "View on GitHub",
            action: #selector(openGitHub),
            systemSymbolName: "chevron.left.forwardslash.chevron.right"
        ))
        menu.addItem(.separator())
        menu.addItem(makeMenuItem(
            title: "Camera Settings",
            action: #selector(openCameraSettings),
            systemSymbolName: "camera"
        ))
        menu.addItem(makeMenuItem(
            title: "Mission Control Shortcuts",
            action: #selector(openKeyboardShortcutsSettings),
            systemSymbolName: "keyboard"
        ))
        menu.addItem(makeMenuItem(
            title: "Quick Help",
            action: #selector(showQuickHelp),
            systemSymbolName: "questionmark.circle"
        ))
        menu.addItem(makeDiagnosticsMenu())
        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit TiltSwitch",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        quitItem.image = NSImage(systemSymbolName: "power", accessibilityDescription: nil)
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
        statusItem?.menu = makeStatusMenu()
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        menu.addItem(makeMenuItem(
            title: "Open Website",
            action: #selector(openWebsite),
            systemSymbolName: "safari"
        ))
        menu.addItem(makeMenuItem(
            title: "View on GitHub",
            action: #selector(openGitHub),
            systemSymbolName: "chevron.left.forwardslash.chevron.right"
        ))
        menu.addItem(makeMenuItem(
            title: "Run Self Check",
            action: #selector(runSelfCheck),
            systemSymbolName: "checklist"
        ))
        menu.addItem(.separator())
        menu.addItem(makeMenuItem(
            title: isEnabled ? "Disable TiltSwitch" : "Enable TiltSwitch",
            action: #selector(toggleEnabled),
            systemSymbolName: isEnabled ? "pause.circle" : "play.circle"
        ))
        menu.addItem(makeMenuItem(
            title: "Quit TiltSwitch",
            action: #selector(quit),
            keyEquivalent: "q",
            systemSymbolName: "power"
        ))
        return menu
    }

    private func makeDiagnosticsMenu() -> NSMenuItem {
        let diagnosticsItem = NSMenuItem(title: "Diagnostics", action: nil, keyEquivalent: "")
        diagnosticsItem.image = NSImage(systemSymbolName: "stethoscope", accessibilityDescription: nil)

        let diagnosticsMenu = NSMenu()
        diagnosticsMenu.addItem(makeMenuItem(
            title: "Run Self Check",
            action: #selector(runSelfCheck),
            systemSymbolName: "checklist"
        ))
        diagnosticsMenu.addItem(.separator())
        diagnosticsMenu.addItem(makeMenuItem(
            title: "Test HUD Left",
            action: #selector(testHUDLeft),
            systemSymbolName: "arrow.left.circle"
        ))
        diagnosticsMenu.addItem(makeMenuItem(
            title: "Test HUD Right",
            action: #selector(testHUDRight),
            systemSymbolName: "arrow.right.circle"
        ))
        diagnosticsMenu.addItem(.separator())
        diagnosticsMenu.addItem(makeMenuItem(
            title: "Test Previous Space",
            action: #selector(testPreviousSpace),
            systemSymbolName: "arrow.left.square"
        ))
        diagnosticsMenu.addItem(makeMenuItem(
            title: "Test Next Space",
            action: #selector(testNextSpace),
            systemSymbolName: "arrow.right.square"
        ))
        diagnosticsItem.submenu = diagnosticsMenu
        return diagnosticsItem
    }

    private func makeMenuItem(
        title: String,
        action: Selector,
        keyEquivalent: String = "",
        systemSymbolName: String
    ) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        item.image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil)
        return item
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

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "TiltSwitch"
        alert.informativeText = "Switch Mission Control spaces with a head tilt.\n\nTilt right for the next space. Tilt left for the previous space."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func showQuickHelp() {
        let alert = NSAlert()
        alert.messageText = "How TiltSwitch Works"
        alert.informativeText = "Keep TiltSwitch enabled, grant camera access, and make sure Mission Control shortcuts for Control + Left/Right Arrow are enabled in System Settings."
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Mission Control Settings")

        if alert.runModal() == .alertSecondButtonReturn {
            openKeyboardShortcutsSettings()
        }
    }

    @objc private func runSelfCheck() {
        let permission: String
        switch HeadTiltMonitor.cameraPermission() {
        case .authorized:
            permission = "Camera permission: OK"
        case .notDetermined:
            permission = "Camera permission: not requested yet"
        case .denied:
            permission = "Camera permission: denied"
        }

        let appState = isEnabled ? "TiltSwitch: enabled" : "TiltSwitch: disabled"
        let screenState = isScreenLocked ? "Screen state: locked or sleeping" : "Screen state: active"
        let sensitivityState = "Sensitivity: \(sensitivity.title) (\(sensitivity.threshold) rad)"

        let alert = NSAlert()
        alert.messageText = "TiltSwitch Self Check"
        alert.informativeText = [
            appState,
            screenState,
            permission,
            sensitivityState,
            "Menu bar item: visible",
            "Dock icon: visible",
            "Mission Control shortcuts: verify Control + Left/Right Arrow in System Settings"
        ].joined(separator: "\n")
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Camera Settings")
        alert.addButton(withTitle: "Keyboard Shortcuts")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            openCameraSettings()
        } else if response == .alertThirdButtonReturn {
            openKeyboardShortcutsSettings()
        }
    }

    @objc private func testHUDLeft() {
        showDiagnosticHUD(.left)
    }

    @objc private func testHUDRight() {
        showDiagnosticHUD(.right)
    }

    @objc private func testPreviousSpace() {
        testSpaceSwitch(.left)
    }

    @objc private func testNextSpace() {
        testSpaceSwitch(.right)
    }

    private func showDiagnosticHUD(_ direction: Direction) {
        guard let panel = hudPanel else {
            return
        }
        hudDisplayController.show(direction, in: panel)
    }

    private func testSpaceSwitch(_ direction: Direction) {
        guard spaceSwitcher.switchSpace(direction) else {
            let alert = NSAlert()
            alert.messageText = "Cooldown Active"
            alert.informativeText = "TiltSwitch waits 800ms between space switches. Try the diagnostic again in a moment."
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
        showDiagnosticHUD(direction)
    }

    @objc private func openWebsite() {
        NSWorkspace.shared.open(AppMetadata.websiteURL)
    }

    @objc private func openGitHub() {
        NSWorkspace.shared.open(AppMetadata.githubURL)
    }

    @objc private func openCameraSettings() {
        NSWorkspace.shared.open(AppMetadata.cameraSettingsURL)
    }

    @objc private func openKeyboardShortcutsSettings() {
        NSWorkspace.shared.open(AppMetadata.keyboardShortcutsSettingsURL)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
