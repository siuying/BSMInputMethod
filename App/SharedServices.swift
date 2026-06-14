import Foundation
import BSMCore
import BSMCandidateUI
import BSMDictionarySQLite

/// Process-wide services shared by every input session: the read-only candidate
/// dictionary over the bundled `bsm.db`, and the single Candidate List window.
@MainActor
enum SharedServices {
    static let dictionary: CandidateDictionary = {
        guard let path = Bundle.main.path(forResource: "bsm", ofType: "db") else {
            fatalError("bsm.db missing from the app bundle")
        }
        do {
            return try SQLiteCandidateDictionary(databasePath: path)
        } catch {
            fatalError("Failed to open bsm.db: \(error)")
        }
    }()

    static let candidateWindow = CandidateWindowController()
}
