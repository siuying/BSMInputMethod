import Testing
import Foundation
import BSMCore
import BSMDictionarySQLite

/// Drives the ComposingBuffer against the real bsm.db, porting the legacy
/// BSMBufferSpec "-candidates" case.
@MainActor
struct ComposingBufferIntegrationTests {
    private func makeBuffer() throws -> ComposingBuffer {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let dictionary = try SQLiteCandidateDictionary(databasePath: root.appendingPathComponent("Data/bsm.db").path)
        return ComposingBuffer(dictionary: dictionary)
    }

    @Test func producesProperCandidates() throws {
        let buffer = try makeBuffer()
        for character in ["9", "9", "1", "9"] { buffer.append(character) }
        #expect(try buffer.candidates().count == 9)

        buffer.append("1")
        #expect(try buffer.candidates().count == 4)
        #expect(try buffer.composedString() == "茸")
    }
}
