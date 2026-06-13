import Testing
@testable import BSMCore

@Test func moduleVersionIsAvailable() {
    #expect(BSMCore.version == "0.0.1")
}
