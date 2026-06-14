//
//  UniversityKitUITests.swift
//  UniversityKitUITests
//
//  Created by Vigen Simonyan on 13.06.26.
//

import XCTest

/// End-to-end flow against the live API: listing loads, a tap pushes Details,
/// Refresh round-trips through the listing module, and back-navigation works.
final class UniversalKitUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testListingToDetailsAndRefreshFlow() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Universities"].waitForExistence(timeout: 10))

        let firstRow = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", "Abu Dhabi University"))
            .firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 20), "Listing should show API (or cached) data")
        firstRow.tap()

        XCTAssertTrue(app.navigationBars["Details"].waitForExistence(timeout: 5))
        let detailsName = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", "Abu Dhabi University"))
            .firstMatch
        XCTAssertTrue(detailsName.exists, "Details should show the passed item without any API call")

        let refreshButton = app.navigationBars["Details"].buttons["Refresh"]
        XCTAssertTrue(refreshButton.exists, "Details must expose a Refresh button")
        refreshButton.tap()

        let upToDate = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", "Up to date."))
            .firstMatch
        XCTAssertTrue(upToDate.waitForExistence(timeout: 20), "Refresh should round-trip through the listing module")

        app.navigationBars["Details"].buttons.firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Universities"].waitForExistence(timeout: 5))
    }
}
