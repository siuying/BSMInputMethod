import Foundation
import BSMDatabaseBuilderLib

// Usage: bsm-db-build [data-dir] [output.db]
// Defaults assume the command is run from the repository root.
let arguments = CommandLine.arguments
let dataDir = arguments.count > 1 ? arguments[1] : "Data"
let outputPath = arguments.count > 2 ? arguments[2] : "Data/bsm.db"

let dataURL = URL(fileURLWithPath: dataDir)

func read(_ name: String) throws -> String {
    try String(contentsOf: dataURL.appendingPathComponent(name), encoding: .utf8)
}

let frequencyText = try read("BIAU1.TXT")
let appletText = try read("bsm_applet.dat")
let extensionText = try read("extension.txt")

let outputURL = URL(fileURLWithPath: outputPath)
try DatabaseBuilder().build(
    frequencyTableText: frequencyText,
    appletText: appletText,
    extensionText: extensionText,
    outputURL: outputURL
)

print("Wrote \(outputURL.path)")
