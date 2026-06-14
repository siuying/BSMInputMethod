import Foundation
import SQLite

/// Builds the bundled `bsm.db` from the UTF-8 dictionary sources, preserving the
/// legacy `ime` schema and insertion order (ADR 0004, ADR 0005, ADR 0011).
public struct DatabaseBuilder {
    public init() {}

    public static let createTableSQL =
        "CREATE TABLE `ime` (`id` integer NOT NULL PRIMARY KEY AUTOINCREMENT, `code` char(6), `word` char(1), `frequency` integer DEFAULT (6000));"
    public static let createCodeIndexSQL = "CREATE INDEX `ime_code_index` ON `ime` (`code`);"
    public static let createFrequencyIndexSQL = "CREATE INDEX `ime_frequency_index` ON `ime` (`frequency`);"

    /// Write a fresh SQLite database at `outputURL` from the source text.
    public func build(
        frequencyTableText: String,
        appletText: String,
        extensionText: String,
        outputURL: URL
    ) throws {
        try? FileManager.default.removeItem(at: outputURL)

        let db = try Connection(outputURL.path)
        try db.execute(Self.createTableSQL)
        try db.execute(Self.createCodeIndexSQL)
        try db.execute(Self.createFrequencyIndexSQL)

        let frequency = FrequencyTable(contents: frequencyTableText)
        // Applet rows first, then extension rows, both in file order.
        let entries = DictionarySource.entries(from: appletText)
            + DictionarySource.entries(from: extensionText)

        let insert = try db.prepare("INSERT INTO ime (code, word, frequency) VALUES (?, ?, ?)")
        try db.transaction {
            for entry in entries {
                try insert.run(entry.code, entry.word, frequency[entry.word])
            }
        }
    }
}
