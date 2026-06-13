import Testing
import Foundation
import SQLite
@testable import BSMDatabaseBuilderLib

/// Locates repository assets relative to this test file:
/// Tests/BSMDatabaseBuilderTests/ -> repo root is three directories up.
private let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
private let dataDir = repoRoot.appendingPathComponent("Data")

private func text(_ name: String) throws -> String {
    try String(contentsOf: dataDir.appendingPathComponent(name), encoding: .utf8)
}

/// Builds a database to a temp file and returns a connection to it.
private func buildTempDatabase() throws -> Connection {
    let output = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("bsm-build-\(UUID().uuidString).db")
    try DatabaseBuilder().build(
        frequencyTableText: try text("BIAU1.TXT"),
        appletText: try text("bsm_applet.dat"),
        extensionText: try text("extension.txt"),
        outputURL: output
    )
    return try Connection(output.path)
}

private func committedDatabase() throws -> Connection {
    try Connection(dataDir.appendingPathComponent("bsm.db").path)
}

private func rows(_ db: Connection, code: String) throws -> [(String, Int)] {
    var result: [(String, Int)] = []
    for row in try db.prepare("SELECT word, frequency FROM ime WHERE code = ? ORDER BY id", code) {
        result.append((row[0] as! String, Int(row[1] as! Int64)))
    }
    return result
}

@Test func generatedSchemaMatchesLegacy() throws {
    let db = try buildTempDatabase()
    let tableSQL = try #require(try db.scalar(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='ime'") as? String)
    #expect(tableSQL == DatabaseBuilder.createTableSQL.replacingOccurrences(of: ";", with: ""))

    let indexNames = try db.prepare("SELECT name FROM sqlite_master WHERE type='index'")
        .map { $0[0] as! String }
    #expect(indexNames.contains("ime_code_index"))
    #expect(indexNames.contains("ime_frequency_index"))
}

@Test func rowAndDistinctWordCountsMatchCommittedDatabase() throws {
    let built = try buildTempDatabase()
    let committed = try committedDatabase()

    let builtCount = try built.scalar("SELECT count(*) FROM ime") as! Int64
    let committedCount = try committed.scalar("SELECT count(*) FROM ime") as! Int64
    #expect(builtCount == committedCount)
    #expect(builtCount == 53936)

    let builtWords = try built.scalar("SELECT count(DISTINCT word) FROM ime") as! Int64
    let committedWords = try committed.scalar("SELECT count(DISTINCT word) FROM ime") as! Int64
    #expect(builtWords == committedWords)
    #expect(builtWords == 16205)
}

@Test(arguments: ["0", "1", "12", "121"])
func candidateRowsMatchCommittedDatabase(code: String) throws {
    let built = try buildTempDatabase()
    let committed = try committedDatabase()
    let builtRows = try rows(built, code: code)
    let committedRows = try rows(committed, code: code)
    #expect(builtRows.map(\.0) == committedRows.map(\.0))
    #expect(builtRows.map(\.1) == committedRows.map(\.1))
}

@Test func entireTableReproducesCommittedDatabase() throws {
    let built = try buildTempDatabase()
    let committed = try committedDatabase()

    struct Row { let code: String; let word: String; let frequency: Int }
    func allRows(_ db: Connection) throws -> [Row] {
        try db.prepare("SELECT code, word, frequency FROM ime ORDER BY id").map {
            Row(code: $0[0] as! String, word: $0[1] as! String, frequency: Int($0[2] as! Int64))
        }
    }

    let builtRows = try allRows(built)
    let committedRows = try allRows(committed)
    #expect(builtRows.count == committedRows.count)

    // Every (code, word) pair must match the committed database exactly, in id
    // order. Frequencies match too, except for a handful of words where the
    // legacy Ruby pipeline left the default 6000 because it decoded BIAU1.TXT
    // (BIG5) and bsm_applet.dat (BIG5-HKSCS) with mapping tables that disagreed
    // on the codepoint, so its frequency lookup missed. The Swift builder uses
    // consistent codecs, so the lookup hits and assigns the real rank.
    for (built, committed) in zip(builtRows, committedRows) {
        #expect(built.code == committed.code)
        #expect(built.word == committed.word)
        if built.frequency != committed.frequency {
            #expect(committed.frequency == FrequencyTable.defaultFrequency)
        }
    }
}

@Test func knownFrequenciesAreParsed() throws {
    let frequency = FrequencyTable(contents: try text("BIAU1.TXT"))
    // Verified against the committed database: 是 -> 5, 口 -> 198, 時 -> 19.
    #expect(frequency["是"] == 5)
    #expect(frequency["口"] == 198)
    #expect(frequency["時"] == 19)
    // A word absent from the ranking falls back to the default.
    #expect(frequency["国"] == FrequencyTable.defaultFrequency)
}
