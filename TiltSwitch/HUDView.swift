import AppKit
import SwiftUI

struct HUDView: View {
    let symbolName: String

    var body: some View {
        ZStack {
            Color.clear
            Image(systemName: symbolName)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 200, height: 60)
        }
        .frame(width: 200, height: 60)
    }
}

final class HUDDisplayController {
    private var hideWorkItem: DispatchWorkItem?

    func show(_ direction: Direction, in panel: NSPanel) {
        hideWorkItem?.cancel()
        panel.contentView = NSHostingView(rootView: HUDView(symbolName: direction.symbolName))
        position(panel)

        panel.alphaValue = 0
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            panel.animator().alphaValue = 1
        }

        let workItem = DispatchWorkItem { [weak panel] in
            guard let panel else {
                return
            }
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.3
                panel.animator().alphaValue = 0
            } completionHandler: {
                panel.orderOut(nil)
            }
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
    }

    private func position(_ panel: NSPanel) {
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { screen in
            screen.frame.contains(mouseLocation)
        } ?? NSScreen.main

        guard let frame = screen?.visibleFrame else {
            return
        }

        let panelSize = NSSize(width: 200, height: 60)
        let x = frame.midX - panelSize.width / 2
        let y = frame.maxY - panelSize.height - 28
        panel.setFrame(NSRect(origin: NSPoint(x: x, y: y), size: panelSize), display: true)
    }
}
