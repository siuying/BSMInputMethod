# BSM Input Method

This context describes the language of the BSM macOS input method and its modernization work.

## Language

**Input Method App Bundle**:
A macOS input method packaged as an application bundle that the system loads as a text input source.
_Avoid_: Framework, plugin

**Input Method**:
The user-facing text input source that converts BSM stroke codes into Chinese characters.
_Avoid_: Keyboard, app

**Behavior Parity**:
The requirement that the modernized input method preserves the existing input, candidate selection, paging, wildcard, deletion, and commit behavior before intentional behavior changes are considered.
_Avoid_: Rewrite freedom, cleanup behavior

**Candidate List**:
The transient list of conversion choices shown while composing BSM input, with a selection number, candidate word, and optionally the candidate's BSM code.
_Avoid_: Suggestions, autocomplete

**Candidate List Parity**:
The requirement that a replacement Candidate List preserve both selection behavior and the visible row semantics of the current list: selection number, candidate word, optional BSM code, paging, caret-relative display, and code visibility toggling.
_Avoid_: Native enough, approximate candidate UI

**Legacy Implementation**:
The existing Objective-C/CocoaPods/Ruby implementation retained under `Legacy/` as a reference during modernization.
_Avoid_: Old project, deprecated app

**BSM Code**:
The raw lookup string used to query candidates: stroke digits `0`-`9` plus the `*` wildcard, at most 6 characters. Excludes the `.` selection trigger.
_Avoid_: Stroke code, code buffer, input code

**Stroke Marker**:
The display representation of the BSM Code shown as marked text while composing, mapping each stroke digit to its stroke glyph (e.g. `1`→`一`, `9`→`十`, `0`→`囗`) and showing `.` and `*` literally. Can be longer than the BSM Code because `.` adds to the marker only.
_Avoid_: Marked text, preview

**Selection Mode**:
The composing state entered by typing `.`, in which digit keys `1`-`9` pick a Candidate by its selection number instead of extending the BSM Code.
_Avoid_: Pick mode, choosing

**Composing Buffer**:
The transient composing state for a single conversion: the BSM Code, the Stroke Marker, Selection Mode, and paging position.
_Avoid_: Input buffer, editor state

**Composed String**:
The candidate word currently staged for commit into the client application.
_Avoid_: Result, output text

## Example Dialogue

Developer: "Are we building a framework?"
Domain expert: "No. The deliverable is an Input Method App Bundle. It may have internal modules, but users install and enable it as an Input Method."

Developer: "Can the Swift version simplify key behavior?"
Domain expert: "Not in the first milestone. Behavior Parity means the Swift version should work exactly like the current input method."

Developer: "What is shown while composing?"
Domain expert: "The Candidate List shows numbered candidate words, and can show each candidate's BSM code."

Developer: "Can we use the system candidate UI?"
Domain expert: "Only if it satisfies Candidate List Parity. If it cannot show the same numbered word/code rows with code toggling, use a custom Candidate List."

Developer: "Where does the Objective-C implementation go?"
Domain expert: "It becomes the Legacy Implementation under `Legacy/`; the repo root represents the modern Swift project."

Developer: "Is the `.` part of the BSM Code?"
Domain expert: "No. `.` enters Selection Mode and only appears in the Stroke Marker. The BSM Code is just the stroke digits and the `*` wildcard, up to 6 characters."

Developer: "So the Stroke Marker and BSM Code can differ in length?"
Domain expert: "Yes. Typing `.` lengthens the Stroke Marker but leaves the BSM Code unchanged. The 6-character limit applies to the BSM Code."

Developer: "What gets inserted when the user commits?"
Domain expert: "The Composed String — the staged candidate word — not the BSM Code or Stroke Marker."
