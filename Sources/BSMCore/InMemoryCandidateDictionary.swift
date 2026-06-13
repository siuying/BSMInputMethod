import Foundation

/// A pure in-memory CandidateDictionary for behavior-parity tests (ADR 0003).
///
/// Reproduces the legacy lookup semantics without SQLite: prefix/wildcard
/// matching via SQL-`LIKE` rules, grouping by word keeping the lowest row id,
/// and ordering by code length then (for wildcard searches) frequency, else row
/// id.
public final class InMemoryCandidateDictionary: CandidateDictionary {
    private struct Entry {
        let id: Int
        let code: String
        let word: String
        let frequency: Int
    }

    private let entries: [Entry]

    public init(entries: [(code: String, word: String, frequency: Int)]) {
        self.entries = entries.enumerated().map {
            Entry(id: $0.offset, code: $0.element.code, word: $0.element.word, frequency: $0.element.frequency)
        }
    }

    public func candidates(matching code: BSMCode, page: Int, pageSize: Int) throws -> [Candidate] {
        let isWildcard = code.raw.contains("*")
        var groups = Array(grouped(matching: code).values)
        if isWildcard {
            groups.sort { ($0.code.count, $0.frequency, $0.id) < ($1.code.count, $1.frequency, $1.id) }
        } else {
            groups.sort { ($0.code.count, $0.id) < ($1.code.count, $1.id) }
        }
        let offset = isWildcard ? page * pageSize : page * 9
        guard offset < groups.count else { return [] }
        return groups[offset..<min(offset + pageSize, groups.count)]
            .map { Candidate(code: BSMCode($0.code), word: $0.word) }
    }

    public func candidateCount(matching code: BSMCode) throws -> Int {
        grouped(matching: code).count
    }

    public func possibleNextCodes(after code: BSMCode) throws -> Set<BSMCode> {
        guard code.raw.count < 6 else { return [] }
        var result: Set<BSMCode> = []
        for digit in "0123456789" {
            let next = BSMCode(code.raw + String(digit))
            if try candidateCount(matching: next) > 0 {
                result.insert(next)
            }
        }
        return result
    }

    private func grouped(matching code: BSMCode) -> [String: Entry] {
        let pattern = Array(code.raw.replacingOccurrences(of: "*", with: "%") + "%")
        let minLength = max(pattern.count - 1, 1)
        var byWord: [String: Entry] = [:]
        for entry in entries where entry.code.count >= minLength
            && Self.likeMatch(pattern, Array(entry.code)) {
            if let existing = byWord[entry.word] {
                if entry.id < existing.id { byWord[entry.word] = entry }
            } else {
                byWord[entry.word] = entry
            }
        }
        return byWord
    }

    /// SQL `LIKE` matching for patterns containing the `%` multi-character
    /// wildcard (the only wildcard BSM codes produce).
    static func likeMatch(_ pattern: [Character], _ text: [Character]) -> Bool {
        var p = 0, t = 0, star = -1, mark = 0
        while t < text.count {
            if p < pattern.count, pattern[p] == "%" {
                star = p; mark = t; p += 1
            } else if p < pattern.count, pattern[p] == text[t] {
                p += 1; t += 1
            } else if star != -1 {
                p = star + 1; mark += 1; t = mark
            } else {
                return false
            }
        }
        while p < pattern.count, pattern[p] == "%" { p += 1 }
        return p == pattern.count
    }
}
