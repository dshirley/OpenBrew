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
    app.launch()
  }

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

  // This function takes screenshots of every screen in OpenBrew. It can be used
  // to verify that the layout looks good on different size screens.
  func testBatchSizeScreenshots() {
    
    let app = XCUIApplication()
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Recipes"].tap()
    tablesQuery.staticTexts["Session IPA"].tap()
    tablesQuery.staticTexts["Batch size"].tap()
    snapshot("BatchSize")
    
    let preBoilVolumeStaticText = tablesQuery.staticTexts["Pre-boil volume"]
    preBoilVolumeStaticText.tap()
    snapshot("BatchSizePreBoilVolume")
    preBoilVolumeStaticText.tap()
    
    let postBoilVolumeStaticText = tablesQuery.staticTexts["Post-boil volume"]
    postBoilVolumeStaticText.tap()
    snapshot("BatchSizePostBoilVolume")
    postBoilVolumeStaticText.tap()
  }

  func testMaltAdditionsScreenshots() {
    let app = XCUIApplication()
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Recipes"].tap()
    tablesQuery.staticTexts["Session IPA"].tap()
    tablesQuery.staticTexts["Malts"].tap()
    snapshot("MaltAdditions")

    let twoRowStaticText = tablesQuery.staticTexts["Two-Row"]
    twoRowStaticText.tap()
    snapshot("MaltAdditionsExpandedWeight")
    twoRowStaticText.tap()

    let toolbarsQuery = app.toolbars
    toolbarsQuery.buttons["Info"].tap()
    snapshot("MaltAdditionsSettings")
    app.buttons["transparentDismissButton"].tap()

    app.navigationBars["Malts"].buttons["Add"].tap()
    snapshot("MaltsList")
  }

  func testHopAdditionsScreenshots() {
    let app = XCUIApplication()
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Recipes"].tap()
    tablesQuery.staticTexts["Session IPA"].tap()
    tablesQuery.staticTexts["Hops"].tap()
    snapshot("HopAdditions")

    let columbusStaticText = XCUIApplication().tables.staticTexts["Columbus"]
    columbusStaticText.tap()
    snapshot("HopAdditionsExpanded")
    columbusStaticText.tap()

    app.toolbars.buttons["Info"].tap()
    snapshot("HopAdditionsSettings")
    app.buttons["transparentDismissButton"].tap()

    app.navigationBars["Hops"].buttons["Add"].tap()
    snapshot("HopsList")
  }

  func testYeastAdditionScreenshots() {
    let app = XCUIApplication()
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Recipes"].tap()
    tablesQuery.staticTexts["Session IPA"].tap()
    tablesQuery.staticTexts["Yeast"].tap()
    snapshot("YeastListWhiteLabs")
    app.toolbars.buttons["Wyeast"].tap()
    snapshot("YeastListWyeast")
  }

  func testCalculationScreenshots() {
    let app = XCUIApplication()
    let tablesQuery = app.tables
    tablesQuery.staticTexts["Strike water"].tap()
    snapshot("StrikeWaterCalculation")
    tablesQuery.staticTexts["Grain weight (lbs)"].tap()
    snapshot("StrikeWaterCalculationExpanded")
    app.navigationBars["Strike Water"].buttons["Back"].tap()

    tablesQuery.staticTexts["Infusion step"].tap()
    snapshot("InfusionStepCalculation")
    tablesQuery.staticTexts["Grain weight (lbs)"].tap()
    app.navigationBars["Mash Infusion"].buttons["Back"].tap()

    tablesQuery.staticTexts["ABV & attenuation"].tap()
    snapshot("AbvCalculation")
    app.navigationBars["Alcohol Percent"].buttons["Back"].tap()

    tablesQuery.staticTexts["Kegging"].tap()
    snapshot("KeggingCalculation")
    app.navigationBars["Keg Carbonation"].buttons["Back"].tap()

    tablesQuery.staticTexts["Priming sugar"].tap()
    snapshot("PrimingSugarCalculation")
    app.navigationBars["Priming Sugar"].buttons["Back"].tap()
  }
}
