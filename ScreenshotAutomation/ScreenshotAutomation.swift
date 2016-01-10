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

  func testRecipesScreenSnapshot() {
    XCUIApplication().tables.staticTexts["Recipes"].tap()
    snapshot("RecipeScreen")
  }

}
