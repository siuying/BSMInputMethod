import XCTest

/// Drives the standalone Example app to verify the Candidate List renders the
/// numbered word / muted code rows and that the `+` code column toggles (#5).
final class CandidateListUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testRowsShowSelectionNumberWordAndCode() {
        XCTAssertTrue(app.staticTexts["candidate-number-1"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["candidate-number-1"].label, "1")
        XCTAssertEqual(app.staticTexts["candidate-word-1"].label, "一")
        XCTAssertEqual(app.staticTexts["candidate-code-1"].label, "1")

        // Nine candidates on the first page -> selection numbers 1...9.
        XCTAssertTrue(app.staticTexts["candidate-number-9"].exists)
        XCTAssertEqual(app.staticTexts["candidate-word-9"].label, "world")
    }

    func testToggleHidesAndShowsCodeColumn() {
        XCTAssertTrue(app.staticTexts["candidate-code-1"].waitForExistence(timeout: 5))

        app.buttons["toggle-code"].click()
        XCTAssertFalse(app.staticTexts["candidate-code-1"].exists)
        // Word column remains.
        XCTAssertTrue(app.staticTexts["candidate-word-1"].exists)

        app.buttons["toggle-code"].click()
        XCTAssertTrue(app.staticTexts["candidate-code-1"].waitForExistence(timeout: 2))
    }

    func testNextPageChangesCandidates() {
        XCTAssertTrue(app.staticTexts["candidate-word-1"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["candidate-word-1"].label, "一")

        app.buttons["next-page"].click()
        XCTAssertEqual(app.staticTexts["candidate-word-1"].label, "中")
        // Second page has three candidates; there is no fourth row.
        XCTAssertFalse(app.staticTexts["candidate-number-4"].exists)
    }
}
