/// BSMCore is the pure Swift domain module for the BSM input method.
///
/// It owns BSM behavior — the Composing Buffer, BSM Code / Stroke Marker
/// mapping, candidate paging, and the Candidate Dictionary lookup boundary —
/// independent of macOS / InputMethodKit so behavior parity can be tested
/// without launching the input method.
public enum BSMCore {
    /// Marker constant so the walking-skeleton module has something to link and test.
    public static let version = "0.0.1"
}
