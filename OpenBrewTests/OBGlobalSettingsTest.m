//
//  OBSettingsTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBGlobalSettings.h"

@interface OBGlobalSettingsTest : XCTestCase

@end

@implementation OBGlobalSettingsTest

- (void)tearDown
{
  NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
  [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)testIbuFormula
{
  XCTAssertEqual([OBGlobalSettings ibuFormula], OBIbuFormulaTinseth, @"The default formula is tinseth");

  [OBGlobalSettings setIbuFormula:OBIbuFormulaTinseth];
  XCTAssertEqual([OBGlobalSettings ibuFormula], OBIbuFormulaTinseth);

  [OBGlobalSettings setIbuFormula:OBIbuFormulaRager];
  XCTAssertEqual([OBGlobalSettings ibuFormula], OBIbuFormulaRager);

  [OBGlobalSettings setIbuFormula:OBIbuFormulaTinseth];
  XCTAssertEqual([OBGlobalSettings ibuFormula], OBIbuFormulaTinseth);
}

- (void)testDefaultPreBoilSize
{
  XCTAssertEqual([[OBGlobalSettings defaultPreBoilSize] floatValue], 7.0, @"The default value is 7.0");

  [OBGlobalSettings setDefaultPreBoilSize:@(54321)];
  XCTAssertEqual([[OBGlobalSettings defaultPreBoilSize] integerValue], 54321);

  [OBGlobalSettings setDefaultPreBoilSize:@(12345)];
  XCTAssertEqual([[OBGlobalSettings defaultPreBoilSize] integerValue], 12345);
}

- (void)testDefaultPostBoilSize
{
  XCTAssertEqual([[OBGlobalSettings defaultPostBoilSize] floatValue], 6.0, @"The default value is 6.0");

  [OBGlobalSettings setDefaultPostBoilSize:@(8888)];
  XCTAssertEqual([[OBGlobalSettings defaultPostBoilSize] integerValue], 8888);

  [OBGlobalSettings setDefaultPostBoilSize:@(3333)];
  XCTAssertEqual([[OBGlobalSettings defaultPostBoilSize] integerValue], 3333);
}

// This class lends itself to copy/paste errors.  Lets make sure a key wasn't copy pasted
// between two different settings
- (void)testForCarelessErrors
{
  [OBGlobalSettings setIbuFormula:OBIbuFormulaRager];
  [OBGlobalSettings setDefaultPreBoilSize:@(54)];
  [OBGlobalSettings setDefaultPostBoilSize:@(98)];

  XCTAssertEqual([OBGlobalSettings ibuFormula], OBIbuFormulaRager);

  [OBGlobalSettings setIbuFormula:OBIbuFormulaTinseth];
  XCTAssertEqual([[OBGlobalSettings defaultPreBoilSize] integerValue], 54);

  [OBGlobalSettings setDefaultPreBoilSize:@(44)];
  XCTAssertEqual([[OBGlobalSettings defaultPostBoilSize] integerValue], 98);
}

@end
