import Cocoa
import InputMethodKit

// The IMKServer must match the InputMethodConnectionName declared in Info.plist
// and stay alive for the lifetime of the process.
let connectionName = "BSMInputMethod_Connection"

guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
    fatalError("BSMInputMethod has no bundle identifier")
}

// Held for the process lifetime; IMK routes client sessions through this server.
let server = IMKServer(name: connectionName, bundleIdentifier: bundleIdentifier)
_ = server

NSApplication.shared.run()
