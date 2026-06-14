import SwiftUI
import BSMCore

/// The Candidate List: numbered candidate words with an optional muted BSM code
/// column. Reproduces the legacy row semantics (selection number, word, and a
/// toggleable code column) as a custom SwiftUI view rather than `IMKCandidates`
/// (ADR 0008).
public struct CandidateListView: View {
    public let candidates: [Candidate]
    public let showsCode: Bool
    public let selectedIndex: Int?

    public init(candidates: [Candidate], showsCode: Bool, selectedIndex: Int? = nil) {
        self.candidates = candidates
        self.showsCode = showsCode
        self.selectedIndex = selectedIndex
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            ForEach(Array(candidates.enumerated()), id: \.offset) { index, candidate in
                CandidateRowView(
                    number: index + 1,
                    word: candidate.word,
                    code: candidate.code.raw,
                    showsCode: showsCode,
                    isSelected: index == selectedIndex
                )
            }
        }
        .padding(6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
        .fixedSize()
        .accessibilityIdentifier("CandidateList")
    }
}

struct CandidateRowView: View {
    let number: Int
    let word: String
    let code: String
    let showsCode: Bool
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text("\(number)")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: 16, alignment: .trailing)
                .accessibilityIdentifier("candidate-number-\(number)")

            Text(word)
                .font(.title3)
                .accessibilityIdentifier("candidate-word-\(number)")

            if showsCode {
                Spacer(minLength: 16)
                Text(code)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .accessibilityIdentifier("candidate-code-\(number)")
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isSelected ? Color.accentColor.opacity(0.25) : Color.clear,
            in: RoundedRectangle(cornerRadius: 4)
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("candidate-row-\(number)")
    }
}
