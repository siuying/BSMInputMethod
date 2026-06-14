import Foundation
import SQLite
import BSMCore

/// SQLite.swift-backed CandidateDictionary over the bundled `bsm.db`,
/// reproducing the legacy `BSMEngine` query semantics (ADR 0003, ADR 0004).
///
/// The database is opened read-only. SQLite.swift types never escape this type;
/// callers see only BSMCore concepts.
public final class SQLiteCandidateDictionary: CandidateDictionary {
    private let db: Connection

    public init(databasePath: String) throws {
        db = try Connection(databasePath, readonly: true)
    }

    init(connection: Connection) {
        db = connection
    }

    /// In-memory dictionary seeded with the given rows; used by tests.
    public static func inMemory(rows: [(code: String, word: String, frequency: Int)]) throws -> SQLiteCandidateDictionary {
        let db = try Connection(.inMemory)
        try db.execute("CREATE TABLE ime (id integer primary key autoincrement, code char(6), word char(1), frequency integer default 6000);")
        let insert = try db.prepare("INSERT INTO ime (code, word, frequency) VALUES (?, ?, ?)")
        for row in rows { try insert.run(row.code, row.word, row.frequency) }
        return SQLiteCandidateDictionary(connection: db)
    }

    public func candidates(matching code: BSMCode, page: Int, pageSize: Int) throws -> [Candidate] {
        let (like, minLength) = Self.likeFilter(for: code)
        let sql: String
        let offset: Int
        if code.raw.contains("*") {
            // Wildcard searches order by code length then frequency.
            sql = "SELECT word, code, min(id) AS minid FROM ime WHERE code LIKE ? AND length(code) >= ? GROUP BY word ORDER BY length(code), frequency LIMIT ? OFFSET ?"
            offset = page * pageSize
        } else {
            // Non-wildcard searches order by code length then original row order.
            // The legacy offset multiplier is a fixed 9, preserved for parity.
            sql = "SELECT word, code, min(id) AS minid FROM ime WHERE code LIKE ? AND length(code) >= ? GROUP BY word ORDER BY length(code), minid LIMIT ? OFFSET ?"
            offset = page * 9
        }

        var results: [Candidate] = []
        for row in try db.prepare(sql, like, minLength, pageSize, offset) {
            let word = row[0] as! String
            let storedCode = row[1] as! String
            results.append(Candidate(code: BSMCode(storedCode), word: word))
        }
        return results
    }

    public func candidateCount(matching code: BSMCode) throws -> Int {
        let (like, minLength) = Self.likeFilter(for: code)
        let sql = "SELECT count(*) FROM (SELECT word FROM ime WHERE code LIKE ? AND length(code) >= ? GROUP BY word)"
        return Int(try db.scalar(sql, like, minLength) as! Int64)
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

    /// Builds the `LIKE` pattern and minimum code length, mirroring the legacy
    /// engine: replace `*` with `%`, append a trailing `%`, and require the
    /// stored code to be at least one shorter than the pattern.
    static func likeFilter(for code: BSMCode) -> (like: String, minLength: Int) {
        let like = code.raw.replacingOccurrences(of: "*", with: "%") + "%"
        return (like, max(like.count - 1, 1))
    }
}
