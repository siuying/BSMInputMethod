import Testing
import SwiftUI
import BSMCore
@testable import BSMCandidateUI

/// Headless rendering checks for the Candidate List. The full interaction
/// coverage lives in the Example app's XCUITests (issue #5); these run in
/// `swift test` without a GUI session.
@MainActor
struct CandidateListViewTests {
    private let candidates = [
        Candidate(code: BSMCode("1"), word: "一"),
        Candidate(code: BSMCode("123456"), word: "七"),
    ]

    @Test func rendersToAnImage() {
        let renderer = ImageRenderer(content: CandidateListView(candidates: candidates, showsCode: true))
        #expect(renderer.cgImage != nil)
    }

    @Test func codeColumnAddsWidth() {
        let withCode = ImageRenderer(content: CandidateListView(candidates: candidates, showsCode: true)).cgImage
        let withoutCode = ImageRenderer(content: CandidateListView(candidates: candidates, showsCode: false)).cgImage
        let withCodeImage = try! #require(withCode)
        let withoutCodeImage = try! #require(withoutCode)
        // Showing the muted BSM code column makes each row wider.
        #expect(withCodeImage.width > withoutCodeImage.width)
    }

    @Test func emptyListStillRenders() {
        let renderer = ImageRenderer(content: CandidateListView(candidates: [], showsCode: true))
        #expect(renderer.cgImage != nil)
    }
}
