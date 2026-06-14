import Foundation

/// The Composing Buffer: the transient state for a single conversion.
///
/// Holds the BSM Code (lookup string of stroke digits plus the `*` wildcard,
/// max 6, excluding `.`) and the Stroke Marker (display glyphs), tracks
/// Selection Mode and paging, and stages a Composed String. Mirrors the legacy
/// `BSMBuffer`: candidate lookups are lazy and run on the main actor (ADR 0010).
@MainActor
public final class ComposingBuffer {
    /// Maximum length of the BSM Code (the `.` trigger does not count).
    public static let maxCodeLength = 6

    private static let markerGlyphs: [Character: Character] = [
        "1": "一", "2": "丨", "3": "丿", "4": "丶", "5": "亅",
        "6": "𠄌", "7": "乂", "8": "八", "9": "十", "0": "囗",
    ]

    private let dictionary: CandidateDictionary
    private var needsUpdate = false
    private var cachedCandidates: [Candidate] = []
    private var cachedComposedString = ""

    /// The BSM Code accumulated so far.
    public private(set) var code = BSMCode("")
    /// The Stroke Marker shown as marked text.
    public private(set) var marker = ""
    /// Whether the buffer is in Selection Mode (entered by typing `.`).
    public private(set) var isSelecting = false
    /// Total number of candidate pages. Settable to mirror the legacy buffer.
    public var numberOfPage = 0
    /// The current candidate page.
    public private(set) var currentPage = 0

    public init(dictionary: CandidateDictionary) {
        self.dictionary = dictionary
    }

    public var isEmpty: Bool { code.raw.isEmpty }

    /// Whether the BSM Code has reached the maximum length.
    public var isCodeFull: Bool { code.raw.count >= Self.maxCodeLength }

    /// Append one input character. `.` enters Selection Mode and only extends
    /// the Stroke Marker; digits and `*` extend the BSM Code. Returns `false`
    /// when the input is rejected (unknown character, or the code is full).
    @discardableResult
    public func append(_ input: String) -> Bool {
        guard input.count == 1, let character = input.first else { return false }

        if character == "." {
            marker.append(".")
            isSelecting = true
            return true
        }

        let glyph: Character
        if character == "*" {
            glyph = "*"
        } else if let mapped = Self.markerGlyphs[character] {
            glyph = mapped
        } else {
            return false
        }

        guard !isCodeFull else { return false }
        marker.append(glyph)
        code = BSMCode(code.raw + String(character))
        needsUpdate = true
        return true
    }

    /// Remove the last Stroke Marker step. Removing the `.` exits Selection
    /// Mode; otherwise one character is removed from the BSM Code too.
    public func deleteBackward() {
        guard let last = marker.last else { return }
        if last == "." {
            isSelecting = false
        } else {
            code = BSMCode(String(code.raw.dropLast()))
            needsUpdate = true
        }
        marker.removeLast()
    }

    /// Replace the Composed String with the candidate at `index`, only while in
    /// Selection Mode. Returns whether a selection was made.
    @discardableResult
    public func setSelectedIndex(_ index: Int) throws -> Bool {
        let candidates = try candidates()
        guard isSelecting, index >= 0, index < candidates.count else { return false }
        cachedComposedString = candidates[index].word
        return true
    }

    /// Advance to the next page, wrapping to the first. Returns `true` on wrap.
    @discardableResult
    public func nextPage() -> Bool {
        let wrapped: Bool
        if currentPage + 1 < numberOfPage {
            currentPage += 1
            wrapped = false
        } else {
            currentPage = 0
            wrapped = true
        }
        needsUpdate = true
        return wrapped
    }

    /// Go to the previous page, wrapping to the last. Returns `true` on wrap.
    @discardableResult
    public func previousPage() -> Bool {
        let wrapped: Bool
        if currentPage > 0 {
            currentPage -= 1
            wrapped = false
        } else {
            currentPage = max(numberOfPage - 1, 0)
            wrapped = true
        }
        needsUpdate = true
        return wrapped
    }

    public func reset() {
        code = BSMCode("")
        marker = ""
        isSelecting = false
        currentPage = 0
        numberOfPage = 0
        cachedCandidates = []
        cachedComposedString = ""
        needsUpdate = false
    }

    /// The candidate list for the current code and page (lazily recomputed).
    public func candidates() throws -> [Candidate] {
        try reloadIfNeeded()
        return cachedCandidates
    }

    /// The Composed String staged for commit (lazily recomputed).
    public func composedString() throws -> String {
        try reloadIfNeeded()
        return cachedComposedString
    }

    /// The possible next codes: all ten digits when empty, otherwise the codes
    /// that still have a match.
    public func possibleNextCodes() throws -> Set<BSMCode> {
        if isEmpty {
            return Set("0123456789".map { BSMCode(String($0)) })
        }
        return try dictionary.possibleNextCodes(after: code)
    }

    private func reloadIfNeeded() throws {
        guard needsUpdate else { return }
        needsUpdate = false
        if code.raw.isEmpty {
            numberOfPage = 1
            cachedCandidates = []
            cachedComposedString = ""
            return
        }
        let count = try dictionary.candidateCount(matching: code)
        numberOfPage = Int(ceil(Double(count) / 9.0))
        cachedCandidates = try dictionary.candidates(matching: code, page: currentPage)
        cachedComposedString = cachedCandidates.first?.word ?? ""
    }
}
