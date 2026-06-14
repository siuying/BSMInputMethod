import AppKit
import SwiftUI
import BSMCore

/// Hosts the Candidate List in a borderless `NSPanel` positioned near the caret
/// (ADR 0008). The panel is non-activating so it does not steal key focus from
/// the client application.
@MainActor
public final class CandidateWindowController {
    private let panel: NSPanel
    private let hostingView: NSHostingView<CandidateListView>

    private var candidates: [Candidate] = []
    private var selectedIndex: Int?

    /// Whether the muted BSM code column is shown (toggled by `+`).
    public private(set) var showsCode = true

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

    /// Show the candidates positioned relative to the caret's line-height
    /// rectangle (in screen coordinates), nudging back on-screen as needed.
    public func display(candidates: [Candidate], showsCode: Bool, selectedIndex: Int?, caretRect: NSRect) {
        self.candidates = candidates
        self.showsCode = showsCode
        self.selectedIndex = selectedIndex
        render()

        var origin = NSPoint(x: caretRect.minX, y: caretRect.minY - panel.frame.height - 4)
        if let visible = NSScreen.main?.visibleFrame {
            if origin.y < visible.minY { origin.y = caretRect.maxY + 4 }
            origin.x = min(origin.x, visible.maxX - panel.frame.width)
        }
        panel.setFrameOrigin(origin)
        panel.orderFront(nil)
    }

    /// Toggle the BSM code column while keeping the panel where it is.
    public func setShowsCode(_ showsCode: Bool) {
        self.showsCode = showsCode
        render()
    }

    public func hide() {
        panel.orderOut(nil)
    }

    private func render() {
        hostingView.rootView = CandidateListView(
            candidates: candidates,
            showsCode: showsCode,
            selectedIndex: selectedIndex
        )
        panel.setContentSize(hostingView.fittingSize)
    }
}
