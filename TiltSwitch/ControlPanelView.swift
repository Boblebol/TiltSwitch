import SwiftUI

struct ControlPanelSensitivityOption: Identifiable, Equatable {
    let id: String
    let title: String
    let thresholdText: String
    let isSelected: Bool
}

struct ControlPanelModel: Equatable {
    let isEnabled: Bool
    let sensitivityTitle: String
    let thresholdText: String
    let cameraStatus: String
    let screenStatus: String
    let menuBarStatus: String
    let versionText: String
    let sensitivityOptions: [ControlPanelSensitivityOption]

    var statusTitle: String {
        isEnabled ? "Enabled" : "Paused"
    }

    static func menuBarStatus(
        itemExists: Bool,
        itemIsVisible: Bool,
        buttonHasWindow: Bool
    ) -> String {
        guard itemExists else {
            return "Menu bar: not created"
        }

        if itemIsVisible, buttonHasWindow {
            return "Menu bar: attached"
        }

        if itemIsVisible {
            return "Menu bar: created, hidden by macOS"
        }

        return "Menu bar: hidden"
    }
}

struct ControlPanelActions {
    let toggleEnabled: () -> Void
    let selectSensitivity: (String) -> Void
    let testLeft: () -> Void
    let testRight: () -> Void
    let runSelfCheck: () -> Void
    let openWebsite: () -> Void
    let openGitHub: () -> Void
    let openCameraSettings: () -> Void
    let openKeyboardShortcutsSettings: () -> Void
    let quit: () -> Void
}

struct ControlPanelView: View {
    let model: ControlPanelModel
    let actions: ControlPanelActions

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            statusBlock
            sensitivityBlock
            diagnosticsBlock
            footer
        }
        .padding(20)
        .frame(width: 360)
        .background(panelBackground)
        .overlay(panelBorder)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.17, green: 0.80, blue: 0.92),
                                Color(red: 0.62, green: 0.92, blue: 0.36)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "figure.walk")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.black)
                    .rotationEffect(.degrees(-8))
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("TiltSwitch")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text("Floating controls")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
            }

            Spacer()

            Text(model.versionText)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.72))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.white.opacity(0.10)))
        }
    }

    private var statusBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(model.isEnabled ? Color(red: 0.62, green: 0.92, blue: 0.36) : Color(red: 1.00, green: 0.72, blue: 0.28))
                    .frame(width: 10, height: 10)
                Text(model.statusTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button(action: actions.toggleEnabled) {
                    Label(model.isEnabled ? "Pause" : "Enable", systemImage: model.isEnabled ? "pause.fill" : "play.fill")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(ControlButtonStyle(kind: .primary))
            }

            VStack(alignment: .leading, spacing: 6) {
                InfoLine(symbolName: "slider.horizontal.3", text: "\(model.sensitivityTitle) sensitivity · \(model.thresholdText)")
                InfoLine(symbolName: "camera", text: model.cameraStatus)
                InfoLine(symbolName: "display", text: model.screenStatus)
                InfoLine(symbolName: "menubar.rectangle", text: model.menuBarStatus)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.08)))
    }

    private var sensitivityBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sensitivity")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.82))

            HStack(spacing: 8) {
                ForEach(model.sensitivityOptions) { option in
                    Button {
                        actions.selectSensitivity(option.id)
                    } label: {
                        VStack(spacing: 2) {
                            Text(option.title)
                                .font(.system(size: 12, weight: .semibold))
                            Text(option.thresholdText)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(option.isSelected ? .black.opacity(0.58) : .white.opacity(0.48))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ControlButtonStyle(kind: option.isSelected ? .selected : .secondary))
                }
            }
        }
    }

    private var diagnosticsBlock: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button(action: actions.testLeft) {
                    Label("Left", systemImage: "arrow.left")
                }
                .buttonStyle(ControlButtonStyle(kind: .secondary))

                Button(action: actions.testRight) {
                    Label("Right", systemImage: "arrow.right")
                }
                .buttonStyle(ControlButtonStyle(kind: .secondary))

                Button(action: actions.runSelfCheck) {
                    Label("Check", systemImage: "checklist")
                }
                .buttonStyle(ControlButtonStyle(kind: .secondary))
            }

            HStack(spacing: 8) {
                Button(action: actions.openCameraSettings) {
                    Label("Camera", systemImage: "camera")
                }
                .buttonStyle(ControlButtonStyle(kind: .secondary))

                Button(action: actions.openKeyboardShortcutsSettings) {
                    Label("Shortcuts", systemImage: "keyboard")
                }
                .buttonStyle(ControlButtonStyle(kind: .secondary))
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Button(action: actions.openWebsite) {
                Label("Website", systemImage: "safari")
            }
            .buttonStyle(ControlButtonStyle(kind: .quiet))

            Button(action: actions.openGitHub) {
                Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
            }
            .buttonStyle(ControlButtonStyle(kind: .quiet))

            Spacer()

            Button(action: actions.quit) {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(ControlButtonStyle(kind: .danger))
        }
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.10, blue: 0.13),
                        Color(red: 0.11, green: 0.16, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .black.opacity(0.36), radius: 24, y: 14)
    }

    private var panelBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.white.opacity(0.14), lineWidth: 1)
    }
}

private struct InfoLine: View {
    let symbolName: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbolName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(red: 0.17, green: 0.80, blue: 0.92))
                .frame(width: 16)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(1)
                .minimumScaleFactor(0.84)
        }
    }
}

private enum ControlButtonKind: Equatable {
    case primary
    case secondary
    case selected
    case quiet
    case danger
}

private struct ControlButtonStyle: ButtonStyle {
    let kind: ControlButtonKind

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(minHeight: 32)
            .frame(maxWidth: kind == .quiet || kind == .danger ? nil : .infinity)
            .background(backgroundColor(configuration: configuration))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
    }

    private var foregroundColor: Color {
        switch kind {
        case .primary, .danger, .secondary, .quiet:
            return .white
        case .selected:
            return .black
        }
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        let opacityMultiplier = configuration.isPressed ? 0.78 : 1

        switch kind {
        case .primary:
            return Color(red: 0.16, green: 0.49, blue: 0.92).opacity(opacityMultiplier)
        case .secondary:
            return Color.white.opacity(configuration.isPressed ? 0.16 : 0.10)
        case .selected:
            return Color(red: 0.62, green: 0.92, blue: 0.36).opacity(opacityMultiplier)
        case .quiet:
            return Color.white.opacity(configuration.isPressed ? 0.12 : 0.06)
        case .danger:
            return Color(red: 0.92, green: 0.20, blue: 0.29).opacity(configuration.isPressed ? 0.80 : 0.68)
        }
    }

    private var borderColor: Color {
        switch kind {
        case .selected:
            return Color.white.opacity(0.18)
        case .danger:
            return Color.white.opacity(0.10)
        case .primary:
            return Color.white.opacity(0.12)
        case .secondary, .quiet:
            return Color.white.opacity(0.10)
        }
    }
}
