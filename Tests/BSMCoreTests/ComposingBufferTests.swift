import Testing
@testable import BSMCore

@MainActor
struct ComposingBufferTests {
    private func makeBuffer(_ entries: [(code: String, word: String, frequency: Int)] = []) -> ComposingBuffer {
        ComposingBuffer(dictionary: InMemoryCandidateDictionary(entries: entries))
    }

    @Test func initialState() throws {
        let buffer = makeBuffer()
        #expect(try buffer.composedString() == "")
        #expect(buffer.marker == "")
        #expect(try buffer.candidates() == [])
    }

    @Test func appendMapsMarkerGlyphs() {
        let buffer = makeBuffer()
        buffer.append("1")
        #expect(buffer.marker == "一")
        buffer.append("2")
        #expect(buffer.marker == "一丨")
    }

    @Test func decimalEntersSelectionMode() {
        let buffer = makeBuffer()
        buffer.append("1")
        buffer.append("2")
        #expect(buffer.isSelecting == false)
        buffer.append(".")
        #expect(buffer.isSelecting)
        #expect(buffer.marker == "一丨.")
    }

    @Test func deleteUpdatesMarker() {
        let buffer = makeBuffer()
        buffer.append("1")
        buffer.append("2")
        #expect(buffer.marker == "一丨")
        buffer.deleteBackward()
        #expect(buffer.marker == "一")
    }

    @Test func deleteExitsSelectionMode() {
        let buffer = makeBuffer()
        buffer.append("1")
        buffer.append("2")
        buffer.append(".")
        #expect(buffer.isSelecting)
        buffer.deleteBackward()
        #expect(buffer.isSelecting == false)
    }

    @Test func appendSixThenDeleteTwice() {
        let buffer = makeBuffer()
        for character in ["6", "6", "4", "6", "6", "4"] { buffer.append(character) }
        buffer.deleteBackward()
        #expect(buffer.code.raw == "66466")
        #expect(buffer.marker == "𠄌𠄌丶𠄌𠄌")
        buffer.deleteBackward()
        #expect(buffer.code.raw == "6646")
        #expect(buffer.marker == "𠄌𠄌丶𠄌")
    }

    @Test func enforcesMaxCodeLength() {
        let buffer = makeBuffer()
        for _ in 0..<6 { #expect(buffer.append("1")) }
        #expect(buffer.isCodeFull)
        #expect(buffer.append("1") == false)
        #expect(buffer.code.raw == "111111")
    }

    @Test func wildcardExtendsCodeAndMarker() {
        let buffer = makeBuffer()
        buffer.append("1")
        buffer.append("*")
        buffer.append("8")
        #expect(buffer.code.raw == "1*8")
        #expect(buffer.marker == "一*八")
    }

    @Test func isEmptyReflectsCode() {
        let buffer = makeBuffer()
        #expect(buffer.isEmpty)
        buffer.append("1")
        #expect(buffer.isEmpty == false)
        buffer.deleteBackward()
        #expect(buffer.isEmpty)
    }

    @Test func nextPageWraps() {
        let buffer = makeBuffer()
        buffer.numberOfPage = 3
        #expect(buffer.currentPage == 0)
        #expect(buffer.nextPage() == false)
        #expect(buffer.currentPage == 1)
        #expect(buffer.nextPage() == false)
        #expect(buffer.currentPage == 2)
        #expect(buffer.nextPage())
        #expect(buffer.currentPage == 0)
    }

    @Test func previousPageWraps() {
        let buffer = makeBuffer()
        buffer.numberOfPage = 3
        #expect(buffer.currentPage == 0)
        #expect(buffer.previousPage())
        #expect(buffer.currentPage == 2)
        #expect(buffer.previousPage() == false)
        #expect(buffer.currentPage == 1)
        #expect(buffer.previousPage() == false)
        #expect(buffer.currentPage == 0)
    }

    @Test func possibleNextCodesWhenEmptyReturnsAllDigits() throws {
        let buffer = makeBuffer()
        let next = try buffer.possibleNextCodes()
        #expect(next == Set("0123456789".map { BSMCode(String($0)) }))
    }

    @Test func possibleNextCodesDelegatesToDictionary() throws {
        let buffer = makeBuffer([("12", "x", 1), ("13", "y", 1)])
        buffer.append("1")
        let next = try buffer.possibleNextCodes()
        #expect(next.contains(BSMCode("12")))
        #expect(next.contains(BSMCode("13")))
        #expect(!next.contains(BSMCode("19")))
    }

    @Test func setSelectedIndexChoosesCandidateInSelectionMode() throws {
        let buffer = makeBuffer([("1", "甲", 1), ("1", "乙", 2)])
        buffer.append("1")
        buffer.append(".")
        #expect(try buffer.candidates().count == 2)
        #expect(try buffer.setSelectedIndex(1))
        #expect(try buffer.composedString() == "乙")
    }

    @Test func setSelectedIndexIgnoredOutsideSelectionMode() throws {
        let buffer = makeBuffer([("1", "甲", 1)])
        buffer.append("1")
        #expect(try buffer.setSelectedIndex(0) == false)
    }
}
