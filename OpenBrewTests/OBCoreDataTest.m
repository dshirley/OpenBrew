//
//  OBCoreDataTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/14/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBMalt.h"
#import "OBHops.h"
#import "OBYeast.h"

@interface OBCoreDataTest : OBBaseTestCase

@end

@implementation OBCoreDataTest

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

@end
