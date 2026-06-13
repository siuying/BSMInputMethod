import AppKit
import SwiftUI
import BSMCore

/// Hosts the Candidate List in a borderless `NSPanel` positioned by the input
/// controller near the caret (ADR 0008). The panel is non-activating so it does
/// not steal key focus from the client application.
@MainActor
public final class CandidateWindowController {
    private let panel: NSPanel
    private let hostingView: NSHostingView<CandidateListView>

    public init() {
        hostingView = NSHostingView(rootView: CandidateListView(candidates: [], showsCode: true))
        panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.hasShadow = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.contentView = hostingView
    }

    public var isVisible: Bool { panel.isVisible }

    /// Replace the displayed candidates and resize the panel to fit.
    public func update(candidates: [Candidate], showsCode: Bool, selectedIndex: Int?) {
        hostingView.rootView = CandidateListView(
            candidates: candidates,
            showsCode: showsCode,
            selectedIndex: selectedIndex
        )
        panel.setContentSize(hostingView.fittingSize)
    }

    /// Show the panel with its top-left corner at `topLeft` in screen coordinates,
    /// nudging it back on-screen if it would overflow the bottom edge.
    public func show(topLeft: NSPoint) {
        panel.setContentSize(hostingView.fittingSize)
        var origin = NSPoint(x: topLeft.x, y: topLeft.y - panel.frame.height)
        if let visible = NSScreen.main?.visibleFrame {
            if origin.y < visible.minY { origin.y = topLeft.y }
            origin.x = min(origin.x, visible.maxX - panel.frame.width)
        }
        panel.setFrameOrigin(origin)
        panel.orderFront(nil)
    }

    public func hide() {
        panel.orderOut(nil)
    }
}
