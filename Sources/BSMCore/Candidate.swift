/// A single conversion choice shown in the Candidate List: the candidate word
/// and the BSM Code it was matched from.
public struct Candidate: Hashable, Sendable {
    public let code: BSMCode
    public let word: String

    public init(code: BSMCode, word: String) {
        self.code = code
        self.word = word
    }
}
