import SwiftUI
import BSMCore
import BSMCandidateUI

/// Standalone harness app for visually reviewing and UI-testing the Candidate
/// List without installing an input method (issue #5). It feeds the shared
/// `CandidateListView` from fixed mock candidate pages.
@main
struct ExampleApp: App {
    var body: some Scene {
        Window("BSM Candidate List Example", id: "main") {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @State private var showsCode = true
    @State private var pageIndex = 0

    static let pages: [[Candidate]] = [
        [
            Candidate(code: BSMCode("1"), word: "一"),
            Candidate(code: BSMCode("12"), word: "下"),
            Candidate(code: BSMCode("123"), word: "丁"),
            Candidate(code: BSMCode("1234"), word: "七"),
            Candidate(code: BSMCode("12345"), word: "丈"),
            Candidate(code: BSMCode("13"), word: "万"),
            Candidate(code: BSMCode("134"), word: "丑"),
            Candidate(code: BSMCode("19"), word: "且"),
            Candidate(code: BSMCode("199"), word: "world"),
        ],
        [
            Candidate(code: BSMCode("2"), word: "中"),
            Candidate(code: BSMCode("23"), word: "串"),
            Candidate(code: BSMCode("234"), word: "丸"),
        ],
    ]

    private var candidates: [Candidate] { Self.pages[pageIndex] }

    var body: some View {
        VStack(spacing: 20) {
            CandidateListView(candidates: candidates, showsCode: showsCode, selectedIndex: 0)

            HStack(spacing: 12) {
                Button("Toggle Code") { showsCode.toggle() }
                    .accessibilityIdentifier("toggle-code")
                Button("Next Page") { pageIndex = (pageIndex + 1) % Self.pages.count }
                    .accessibilityIdentifier("next-page")
            }
            Text("Page \(pageIndex + 1) of \(Self.pages.count)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("page-indicator")
        }
        .padding(40)
        .frame(minWidth: 380, minHeight: 360)
    }
}
