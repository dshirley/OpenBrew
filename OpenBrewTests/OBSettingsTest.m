//
//  OBSettingsTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//
// A lot of data gets loaded.  We'll do some basic sanity tests in this TestCase
//
// TODO: rename this or move the tests into some other location. Perhapse CoreData tests?

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBMalt.h"
#import "OBHops.h"
#import "OBYeast.h"

#import "OBSettings.h"
#import "OBHopAddition.h"

@interface OBSettingsTest : OBBaseTestCase

@end

@implementation OBSettingsTest

- (void)testYeastsWereLoaded
{
  XCTAssertEqual(91, [self fetchAllEntity:@"Yeast"].count);

  OBYeast *yeast = [self fetchEntity:@"Yeast" withProperty:@"identifier" equalTo:@"1007"];
  XCTAssertEqualObjects(@"German Ale", yeast.name);
  XCTAssertEqualObjects(@"1007", yeast.identifier);
  XCTAssertEqual(OBYeastManufacturerWyeast, [yeast.manufacturer integerValue]);

  yeast = [self fetchEntity:@"Yeast" withProperty:@"identifier" equalTo:@"WLP940"];
  XCTAssertEqualObjects(@"Mexican Lager", yeast.name);
  XCTAssertEqualObjects(@"WLP940", yeast.identifier);
  XCTAssertEqual(OBYeastManufacturerWhiteLabs, [yeast.manufacturer integerValue]);
}

- (void)testHopsWereLoaded
{
  XCTAssertEqual(64, [self fetchAllEntity:@"Hops"].count);

  OBHops *hops = [self fetchEntity:@"Hops" withProperty:@"name" equalTo:@"Admiral"];
  XCTAssertEqualObjects(@"Admiral", hops.name);
  XCTAssertEqualWithAccuracy(15.0, [hops.alphaAcidPercent floatValue], 0.0001);

  hops = [self fetchEntity:@"Hops" withProperty:@"name" equalTo:@"Zythos"];
  XCTAssertEqualObjects(@"Zythos", hops.name);
  XCTAssertEqualWithAccuracy(11.25, [hops.alphaAcidPercent floatValue], 0.0001);
}

- (void)testMaltsWereLoaded
{
  XCTAssertEqual(83, [self fetchAllEntity:@"Malt"].count);

  // Test the first one in the CSV
  OBMalt *malt = [self fetchEntity:@"Malt" withProperty:@"name" equalTo:@"Acid Malt"];
  XCTAssertEqualObjects(@"Acid Malt", malt.name);
  XCTAssertEqualWithAccuracy(1.027, [malt.extractPotential floatValue], 0.00001);
  XCTAssertEqual(3, [malt.lovibond integerValue]);
  XCTAssertEqual(OBMaltTypeGrain, [malt.type integerValue]);

  // Test the last one in the CSV
  malt = [self fetchEntity:@"Malt" withProperty:@"name" equalTo:@"Wheat LME"];
  XCTAssertEqualObjects(@"Wheat LME", malt.name);
  XCTAssertEqualWithAccuracy(1.036, [malt.extractPotential floatValue], 0.00001);
  XCTAssertEqual(2, [malt.lovibond integerValue]);
  XCTAssertEqual(OBMaltTypeExtract, [malt.type integerValue]);
}

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
