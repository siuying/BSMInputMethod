import Foundation

/// A single dictionary row before frequency is attached.
public struct DictionaryEntry: Equatable {
    public let code: String
    public let word: String

    public init(code: String, word: String) {
        self.code = code
        self.word = word
    }
}

/// Parses `(code, word)` pairs from the applet and extension source text.
///
/// Mirrors the legacy Ruby regex `/(.{1,6}) (.)/` applied to each line, taking
/// the first match. Lines are kept in file order so the generated row ids match
/// the legacy database, which the non-wildcard lookup ordering depends on.
public enum DictionarySource {
    public static func entries(from contents: String) -> [DictionaryEntry] {
        // Mirror Ruby exactly: `each_line` splits on "\n" keeping a trailing
        // "\r", and "." in the regex matches "\r". `components(separatedBy:)` is
        // UTF-16 based, so it splits a CRLF into "...\r" + "" (unlike Swift's
        // grapheme-aware Character split). `dotMatchesNewlines()` then lets "."
        // match the trailing "\r", reproducing the legacy rows where a malformed
        // line yields a carriage-return "word".
        let pattern = (/(.{1,6}) (.)/).dotMatchesNewlines()
        var result: [DictionaryEntry] = []
        for line in contents.components(separatedBy: "\n") {
            if let match = line.firstMatch(of: pattern) {
                result.append(DictionaryEntry(code: String(match.1), word: String(match.2)))
            }
        }
        return result
    }
}
