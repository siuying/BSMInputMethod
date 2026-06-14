import Testing
import Foundation
import BSMCore
@testable import BSMDictionarySQLite

private let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()

private func dictionary() throws -> SQLiteCandidateDictionary {
    try SQLiteCandidateDictionary(databasePath: repoRoot.appendingPathComponent("Data/bsm.db").path)
}

private func words(_ candidates: [Candidate]) -> [String] { candidates.map(\.word) }

/// Ports BSMEngineSpec against the committed bsm.db.
struct SQLiteCandidateDictionaryTests {
    @Test(arguments: [
        ("121", "工"), ("53", "刀"), ("32562", "他"), ("301453", "的"),
    ])
    func matchesExactCode(code: String, word: String) throws {
        let result = try dictionary().candidates(matching: BSMCode(code), page: 0)
        #expect(result.contains(Candidate(code: BSMCode(code), word: word)))
    }

    @Test func returnsAtMostNinePerPage() throws {
        #expect(try dictionary().candidates(matching: BSMCode("1"), page: 0).count <= 9)
    }

    @Test func honorsRequestedPageSize() throws {
        #expect(try dictionary().candidates(matching: BSMCode("1"), page: 0, pageSize: 20).count == 20)
    }

    @Test func firstCandidateForCode4IsExpected() throws {
        let first = try #require(try dictionary().candidates(matching: BSMCode("4"), page: 0).first)
        #expect(first.word == "這")
    }

    @Test func wildcardFindsDeepMatchAcrossPages() throws {
        let dict = try dictionary()
        let count = try dict.candidateCount(matching: BSMCode("325*2"))
        #expect(count >= 1)
        let pages = Int(ceil(Double(count) / 9.0))
        var found = false
        for page in 0..<pages where try dict.candidates(matching: BSMCode("325*2"), page: page)
            .contains(Candidate(code: BSMCode("32562"), word: "他")) {
            found = true
        }
        #expect(found)
    }

    @Test func wildcardExcludesShorterCode() throws {
        let dict = try dictionary()
        let count = try dict.candidateCount(matching: BSMCode("325*2"))
        let pages = Int(ceil(Double(count) / 9.0))
        var found = false
        for page in 0..<pages where try dict.candidates(matching: BSMCode("325*2"), page: page)
            .contains(Candidate(code: BSMCode("3252"), word: "師")) {
            found = true
        }
        #expect(!found)
    }

    @Test func wildcardOrdersByFrequency() throws {
        let result = try dictionary().candidates(matching: BSMCode("1*8"), page: 0)
        #expect(result.contains(Candidate(code: BSMCode("118"), word: "天")))
    }

    @Test func paginationFillsEveryPageButTheLast() throws {
        let dict = try dictionary()
        let count = try dict.candidateCount(matching: BSMCode("122"))
        let pages = Int(ceil(Double(count) / 9.0))
        var collected = 0
        for page in 0..<pages {
            let pageResult = try dict.candidates(matching: BSMCode("122"), page: page)
            if page + 1 < pages { #expect(pageResult.count == 9) }
            collected += pageResult.count
        }
        #expect(collected == count)
    }

    @Test(arguments: [("99991", 2), ("11119", 1), ("11119111", 0)])
    func countsDistinctMatches(code: String, expected: Int) throws {
        #expect(try dictionary().candidateCount(matching: BSMCode(code)) == expected)
    }

    @Test func possibleNextCodesMatchesLegacy() throws {
        let next = try dictionary().possibleNextCodes(after: BSMCode("118"))
        for digit in ["1", "2", "4", "6", "8", "9", "0"] {
            #expect(next.contains(BSMCode("118" + digit)))
        }
        for digit in ["3", "5", "7"] {
            #expect(!next.contains(BSMCode("118" + digit)))
        }
    }

    @Test func possibleNextCodesEmptyAtMaxLength() throws {
        #expect(try dictionary().possibleNextCodes(after: BSMCode("123456")).isEmpty)
    }

    /// The pure in-memory fake (used by buffer tests) must agree with the SQLite
    /// engine on identical data, so it is a trustworthy substitute.
    @Test func inMemoryFakeAgreesWithSQLite() throws {
        let rows: [(code: String, word: String, frequency: Int)] = [
            ("1", "一", 3), ("1", "不", 2), ("11", "二", 50), ("118", "天", 9),
            ("128", "夫", 40), ("12", "下", 7), ("121", "工", 103), ("13", "万", 60),
        ]
        let fake = InMemoryCandidateDictionary(entries: rows)
        let sqlite = try SQLiteCandidateDictionary.inMemory(rows: rows)

        for code in ["1", "12", "1*8", "118", "9"] {
            let bsm = BSMCode(code)
            #expect(try words(fake.candidates(matching: bsm, page: 0))
                == words(sqlite.candidates(matching: bsm, page: 0)))
            #expect(try fake.candidateCount(matching: bsm)
                == sqlite.candidateCount(matching: bsm))
        }
        #expect(try fake.possibleNextCodes(after: BSMCode("1"))
            == sqlite.possibleNextCodes(after: BSMCode("1")))
    }
}
