import Foundation

/// Word → rank frequency table parsed from `BIAU1.TXT`.
///
/// Mirrors the legacy Ruby `WordFrequency`: each CRLF-delimited line exposes a
/// 7-character rank field at codepoint offset 7 and the word at codepoint
/// offset 16. Lower rank means more frequent; unknown words fall back to the
/// default frequency.
public struct FrequencyTable {
    public static let defaultFrequency = 6000

    private let ranks: [String: Int]

    public init(contents: String) {
        var ranks: [String: Int] = [:]
        for line in contents.components(separatedBy: "\r\n") {
            let chars = Array(line)
            // Need at least index 16 for the word; the rank field is chars 7..<14.
            guard chars.count > 16 else { continue }
            let rankField = String(chars[7..<14]).trimmingCharacters(in: .whitespaces)
            let rank = FrequencyTable.leadingInt(rankField)
            let word = String(chars[16])
            if rank > 0 && !word.isEmpty {
                ranks[word] = rank
            }
        }
        self.ranks = ranks
    }

    public subscript(word: String) -> Int {
        ranks[word] ?? FrequencyTable.defaultFrequency
    }

    /// Number of words with an explicit rank.
    public var rankedWordCount: Int { ranks.count }

    /// Ruby `String#to_i` semantics: parse an optional leading sign followed by
    /// leading digits, ignoring any trailing characters; 0 when there are none.
    static func leadingInt(_ s: String) -> Int {
        var digits = ""
        for ch in s {
            if ch.isNumber || (digits.isEmpty && (ch == "-" || ch == "+")) {
                digits.append(ch)
            } else {
                break
            }
        }
        return Int(digits) ?? 0
    }
}
