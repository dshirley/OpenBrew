//
//  OBSettingsTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBSettings.h"

@interface OBSettingsTest : XCTestCase

@end

@implementation OBSettingsTest

- (void)tearDown
{
  NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
  [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)testIbuFormula
{
  XCTAssertEqual([OBSettings ibuFormula], OBIbuFormulaTinseth, @"The default formula is tinseth");

  [OBSettings setIbuFormula:OBIbuFormulaTinseth];
  XCTAssertEqual([OBSettings ibuFormula], OBIbuFormulaTinseth);

  [OBSettings setIbuFormula:OBIbuFormulaRager];
  XCTAssertEqual([OBSettings ibuFormula], OBIbuFormulaRager);

  [OBSettings setIbuFormula:OBIbuFormulaTinseth];
  XCTAssertEqual([OBSettings ibuFormula], OBIbuFormulaTinseth);
}

- (void)testDefaultPreBoilSize
{
  XCTAssertEqual([[OBSettings defaultPreBoilSize] floatValue], 7.0, @"The default value is 7.0");

  [OBSettings setDefaultPreBoilSize:@(54321)];
  XCTAssertEqual([[OBSettings defaultPreBoilSize] integerValue], 54321);

  [OBSettings setDefaultPreBoilSize:@(12345)];
  XCTAssertEqual([[OBSettings defaultPreBoilSize] integerValue], 12345);
}

- (void)testDefaultPostBoilSize
{
  XCTAssertEqual([[OBSettings defaultPostBoilSize] floatValue], 6.0, @"The default value is 6.0");

  [OBSettings setDefaultPostBoilSize:@(8888)];
  XCTAssertEqual([[OBSettings defaultPostBoilSize] integerValue], 8888);

  [OBSettings setDefaultPostBoilSize:@(3333)];
  XCTAssertEqual([[OBSettings defaultPostBoilSize] integerValue], 3333);
}

// This class lends itself to copy/paste errors.  Lets make sure a key wasn't copy pasted
// between two different settings
- (void)testForCarelessErrors
{
  [OBSettings setIbuFormula:OBIbuFormulaRager];
  [OBSettings setDefaultPreBoilSize:@(54)];
  [OBSettings setDefaultPostBoilSize:@(98)];

  XCTAssertEqual([OBSettings ibuFormula], OBIbuFormulaRager);

  [OBSettings setIbuFormula:OBIbuFormulaTinseth];
  XCTAssertEqual([[OBSettings defaultPreBoilSize] integerValue], 54);

  [OBSettings setDefaultPreBoilSize:@(44)];
  XCTAssertEqual([[OBSettings defaultPostBoilSize] integerValue], 98);
}

@end
