import Cocoa
import Carbon.HIToolbox
import InputMethodKit
import BSMCore
import BSMCandidateUI

/// The BSM input controller. Routes numeric-keypad events into the Composing
/// Buffer, drives marked text and the Candidate List, and commits the Composed
/// String — reproducing the legacy `BSMInputMethodController` behavior (ADR
/// 0009, 0010). Loaded by IMK as `BSMInputMethod.InputController`.
@MainActor
final class InputController: IMKInputController {
    private let buffer = ComposingBuffer(dictionary: SharedServices.dictionary)
    private var candidateWindow: CandidateWindowController { SharedServices.candidateWindow }
    private var showsCode = true
    private weak var currentClient: (any IMKTextInput)?

    override func inputText(_ string: String!, key keyCode: Int, modifiers flags: Int, client sender: Any!) -> Bool {
        guard let client = sender as? any IMKTextInput else { return false }
        currentClient = client
        do {
            return try handle(string ?? "", keyCode: keyCode, client: client)
        } catch {
            return false
        }
    }

    private func handle(_ string: String, keyCode: Int, client: any IMKTextInput) throws -> Bool {
        switch keyCode {
        case kVK_ANSI_KeypadDecimal:
            guard !buffer.isEmpty else { return false }
            if buffer.isSelecting {
                return try selectFirstCandidate(client)
            } else {
                return try appendBuffer(string, client: client)
            }

        case kVK_ANSI_Keypad0...kVK_ANSI_Keypad9, kVK_ANSI_KeypadMultiply:
            if buffer.isSelecting, keyCode != kVK_ANSI_KeypadMultiply {
                guard keyCode > kVK_ANSI_Keypad0 else { beep(); return true }
                if try buffer.setSelectedIndex(selectionIndex(for: keyCode)) {
                    commit(client)
                } else {
                    beep()
                }
                return true
            } else if !buffer.isCodeFull {
                return try appendBuffer(string, client: client)
            } else {
                beep()
                return true
            }

        case kVK_ANSI_KeypadMinus:
            return try minusBuffer(client)

        case kVK_ANSI_KeypadPlus:
            guard !buffer.isEmpty else { return false }
            showsCode.toggle()
            candidateWindow.setShowsCode(showsCode)
            return true

        case kVK_ANSI_KeypadEnter, kVK_Space:
            guard !buffer.isEmpty else { return false }
            if try !buffer.composedString().isEmpty {
                return try selectFirstCandidate(client)
            } else {
                beep()
                return true
            }

        case kVK_ANSI_KeypadDivide:
            guard !buffer.isEmpty else { return false }
            if buffer.nextPage() { beep() }
            try showCandidateWindow(client)
            return true

        case kVK_ANSI_KeypadEquals:
            guard !buffer.isEmpty else { return false }
            if buffer.previousPage() { beep() }
            try showCandidateWindow(client)
            return true

        case kVK_ANSI_KeypadClear:
            clearInput(client)
            return true

        default:
            return false
        }
    }

    /// Keypad digit key codes are contiguous for 1...7 but not 8/9.
    private func selectionIndex(for keyCode: Int) -> Int {
        switch keyCode {
        case kVK_ANSI_Keypad1...kVK_ANSI_Keypad7: return keyCode - kVK_ANSI_Keypad1
        case kVK_ANSI_Keypad8: return 7
        case kVK_ANSI_Keypad9: return 8
        default: return 0
        }
    }

    private func appendBuffer(_ string: String, client: any IMKTextInput) throws -> Bool {
        currentClient = client
        buffer.append(string)
        updateMarkedText(client)
        try showCandidateWindow(client)
        return true
    }

    private func minusBuffer(_ client: any IMKTextInput) throws -> Bool {
        currentClient = client
        guard !buffer.isEmpty else { return false }
        buffer.deleteBackward()
        updateMarkedText(client)
        if try !buffer.composedString().isEmpty {
            try showCandidateWindow(client)
        } else {
            candidateWindow.hide()
        }
        return true
    }

    private func selectFirstCandidate(_ client: any IMKTextInput) throws -> Bool {
        if try !buffer.candidates().isEmpty, try !buffer.composedString().isEmpty {
            commit(client)
        } else {
            beep()
        }
        return true
    }

    private func updateMarkedText(_ client: any IMKTextInput) {
        let marker = buffer.marker
        client.setMarkedText(
            attributedMarker(marker),
            selectionRange: NSRange(location: marker.utf16.count, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
        )
    }

    private func attributedMarker(_ string: String) -> NSAttributedString {
        let range = NSRange(location: 0, length: string.utf16.count)
        let attributes = mark(forStyle: kTSMHiliteRawText, at: range) as? [NSAttributedString.Key: Any]
        return NSAttributedString(string: string, attributes: attributes)
    }

    private func clearInput(_ client: any IMKTextInput) {
        client.setMarkedText(
            "",
            selectionRange: NSRange(location: NSNotFound, length: NSNotFound),
            replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
        )
        buffer.reset()
        cancelComposition()
        candidateWindow.hide()
    }

    private func commit(_ client: any IMKTextInput) {
        // Work around the premature-commit issue in Terminal: defer marked text
        // instead of inserting (matches the legacy controller).
        if client.bundleIdentifier() == "com.apple.Terminal",
           String(describing: type(of: client)) != "IPMDServerClientWrapper" {
            DispatchQueue.main.async { [weak self] in self?.updateMarkedText(client) }
            return
        }
        let composed = (try? buffer.composedString()) ?? ""
        client.insertText(composed, replacementRange: NSRange(location: NSNotFound, length: NSNotFound))
        buffer.reset()
        candidateWindow.hide()
    }

    override func commitComposition(_ sender: Any!) {
        guard let client = sender as? any IMKTextInput else { return }
        commit(client)
    }

    override func cancelComposition() {
        super.cancelComposition()
        buffer.reset()
        candidateWindow.hide()
    }

    override func deactivateServer(_ sender: Any!) {
        if !buffer.isEmpty {
            buffer.reset()
            (sender as? any IMKTextInput)?.setMarkedText(
                "",
                selectionRange: NSRange(location: 0, length: 0),
                replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
            )
        }
        candidateWindow.hide()
        currentClient = nil
    }

    private func showCandidateWindow(_ client: any IMKTextInput) throws {
        let candidates = try buffer.candidates()
        guard !candidates.isEmpty else {
            candidateWindow.hide()
            return
        }

        var lineRect = NSRect(x: 0, y: 0, width: 16, height: 16)
        var cursorIndex = selectionRange().location
        if cursorIndex == buffer.marker.utf16.count, cursorIndex > 0 {
            cursorIndex -= 1
        }
        _ = client.attributes(forCharacterIndex: cursorIndex, lineHeightRectangle: &lineRect)

        candidateWindow.display(
            candidates: candidates,
            showsCode: showsCode,
            selectedIndex: nil,
            caretRect: lineRect
        )
    }

    private func beep() {
        NSSound.beep()
    }
}
