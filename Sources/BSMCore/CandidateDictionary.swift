/// The lookup boundary owned by BSMCore (ADR 0003). Implementations resolve a
/// BSM Code into candidate words; SQLite.swift (or any other backend) stays
/// hidden behind this protocol so the rest of the system speaks only BSM
/// concepts and tests can substitute an in-memory fake.
public protocol CandidateDictionary {
    /// Candidate words matching `code`, grouped by word, for the given page.
    /// A `*` in the code is a wildcard.
    func candidates(matching code: BSMCode, page: Int, pageSize: Int) throws -> [Candidate]

    /// Number of distinct candidate words matching `code`.
    func candidateCount(matching code: BSMCode) throws -> Int

    /// The set of one-character extensions of `code` that still have at least
    /// one match. Empty once the code reaches the 6-character limit.
    func possibleNextCodes(after code: BSMCode) throws -> Set<BSMCode>
}

public extension CandidateDictionary {
    /// Convenience for the default page size of 9 candidates.
    func candidates(matching code: BSMCode, page: Int) throws -> [Candidate] {
        try candidates(matching: code, page: page, pageSize: 9)
    }
}
