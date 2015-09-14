//
//  OBSettingsTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//
// A lot of data gets loaded.  We'll do some basic sanity tests in this TestCase
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBSettings.h"
#import "OBHopAddition.h"

@interface OBSettingsTest : OBBaseTestCase

@end

@implementation OBSettingsTest

- (void)testIbuFormula
{
  XCTAssertEqual([self.settings.ibuFormula integerValue], OBIbuFormulaTinseth, @"The default formula is tinseth");

  self.settings.ibuFormula = @(OBIbuFormulaTinseth);
  XCTAssertEqual([self.settings.ibuFormula integerValue], OBIbuFormulaTinseth);

  self.settings.ibuFormula = @(OBIbuFormulaRager);
  XCTAssertEqual([self.settings.ibuFormula integerValue], OBIbuFormulaRager);

  self.settings.ibuFormula = @(OBIbuFormulaTinseth);
  XCTAssertEqual([self.settings.ibuFormula integerValue], OBIbuFormulaTinseth);

}

- (void)testDefaultPreBoilVolumeInGallons
{
  XCTAssertEqualWithAccuracy(7.0, [self.settings.defaultPreBoilSize floatValue], 0.001);

  self.settings.defaultPreBoilSize = @(8.12);
  XCTAssertEqualWithAccuracy(8.12, [self.settings.defaultPreBoilSize floatValue], 0.000001);
}

- (void)testDefaultPostBoilVolumeInGallons
{
  XCTAssertEqualWithAccuracy(6.0, [self.settings.defaultPostBoilSize floatValue], 0.001);

  self.settings.defaultPostBoilSize = @(9.93);
  XCTAssertEqualWithAccuracy(9.93, [self.settings.defaultPostBoilSize floatValue], 0.000001);
}

@end
