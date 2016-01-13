//
//  ScreenshotAutomation.swift
//  ScreenshotAutomation
//
//  Created by David Shirley 2 on 1/10/16.
//  Copyright © 2016 OpenBrew. All rights reserved.
//

import XCTest

class ScreenshotAutomation: XCTestCase {

  override func setUp() {
    super.setUp()

    continueAfterFailure = false
    let app = XCUIApplication()
    setupSnapshot(app)
    app.launch()    }

  override func tearDown() {
    super.tearDown()
  }

  func testGetiTunesScreenShots() {
    snapshot("TableOfContents")

    let app = XCUIApplication()
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Recipes"].tap()

    tablesQuery.staticTexts["Session IPA"].tap()
    snapshot("RecipeOverview")

    tablesQuery.staticTexts["Hops"].tap()
    tablesQuery.staticTexts["Columbus"].tap()
    snapshot("HopAdditions")

    app.toolbars.buttons["Info"].tap()
    snapshot("HopAdditionSettings")

    let hopsNavigationBar = app.navigationBars["Hops"]
    hopsNavigationBar.buttons["Done"].tap()
    hopsNavigationBar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()

    app.navigationBars["OBRecipeView"].buttons["Recipes"].tap()
    app.navigationBars["Recipes"].buttons["Brew Lab"].tap()

    tablesQuery.staticTexts["ABV & attenuation"].tap()
    snapshot("AbvCalculation")
  }

}
