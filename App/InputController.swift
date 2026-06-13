import Cocoa
import InputMethodKit

/// Walking-skeleton input controller.
///
/// This proves the InputMethodKit plumbing end-to-end: it loads from the
/// `InputMethodServerControllerClass` declared in Info.plist (the
/// module-namespaced `BSMInputMethod.InputController`), receives key events,
/// and echoes numeric-keypad input straight into the client. Real BSM
/// composition, the Candidate Dictionary, and the Candidate List arrive in
/// later slices.
@MainActor
final class InputController: IMKInputController {
    override func inputText(
        _ string: String!,
        key keyCode: Int,
        modifiers flags: Int,
        client sender: Any!
    ) -> Bool {
        guard let client = sender as? IMKTextInput else { return false }

        // Only handle the numeric keypad; let every other key fall through to
        // the system so normal typing is unaffected.
        let isKeypad = (flags & Int(NSEvent.ModifierFlags.numericPad.rawValue)) != 0
        guard isKeypad, let text = string, !text.isEmpty else { return false }

        client.insertText(text, replacementRange: NSRange(location: NSNotFound, length: 0))
        return true
    }
}
