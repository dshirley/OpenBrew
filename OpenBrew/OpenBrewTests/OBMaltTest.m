//
//  OBMaltTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBMalt.h"

@interface OBMaltTest : OBBaseTestCase

@end

@implementation OBMaltTest

- (OBMalt *)createTestMalt {
  return [[OBMalt alloc] initWithCatalog:self.brewery.ingredientCatalog
                                    name:@"test malt"
                        extractPotential:@(0)
                                lovibond:@(0)
                                    type:@(OBMaltTypeExtract)];
}

// Test initializing with a grain, extract, and sugar from MaltCatalog.csv
- (void)testInitWithCatalogAndCsvData
{
  NSArray *csvData = @[ @"Pilsner Malt", @"1.036", @"2", @"0" ];
  OBMalt *malt = [[OBMalt alloc] initWithCatalog:self.brewery.ingredientCatalog andCsvData:csvData];

  XCTAssertEqual(self.brewery.ingredientCatalog, malt.catalog);
  XCTAssertEqualObjects(@"Pilsner Malt", malt.name);
  XCTAssertEqualWithAccuracy(1.036, [malt.defaultExtractPotential floatValue], 0.00001);
  XCTAssertEqual(2, [malt.defaultLovibond integerValue]);
  XCTAssertEqualObjects(@(OBMaltTypeGrain), malt.type);

  csvData = @[ @"Rye LME", @"1.035", @"4", @"2" ];
  malt = [[OBMalt alloc] initWithCatalog:self.brewery.ingredientCatalog andCsvData:csvData];

  XCTAssertEqual(self.brewery.ingredientCatalog, malt.catalog);
  XCTAssertEqualObjects(@"Rye LME", malt.name);
  XCTAssertEqualWithAccuracy(1.035, [malt.defaultExtractPotential floatValue], 0.00001);
  XCTAssertEqual(4, [malt.defaultLovibond integerValue]);
  XCTAssertEqualObjects(@(OBMaltTypeExtract), malt.type);


  csvData = @[ @"Brown Sugar (Dark)", @"1.046", @"50", @"1" ];
  malt = [[OBMalt alloc] initWithCatalog:self.brewery.ingredientCatalog andCsvData:csvData];

  XCTAssertEqual(self.brewery.ingredientCatalog, malt.catalog);
  XCTAssertEqualObjects(@"Brown Sugar (Dark)", malt.name);
  XCTAssertEqualWithAccuracy(1.046, [malt.defaultExtractPotential floatValue], 0.00001);
  XCTAssertEqual(50, [malt.defaultLovibond integerValue]);
  XCTAssertEqualObjects(@(OBMaltTypeSugar), malt.type);
}

- (void)testInitWithCatalogNameExtractLovibondType
{
  OBMalt *malt = [[OBMalt alloc] initWithCatalog:self.brewery.ingredientCatalog
                                            name:@"Slim Shady"
                                extractPotential:@(123.456)
                                        lovibond:@(78.9)
                                            type:@(OBMaltTypeSugar)];

  XCTAssertEqual(self.brewery.ingredientCatalog, malt.catalog);
  XCTAssertEqualObjects(@"Slim Shady", malt.name);
  XCTAssertEqualWithAccuracy(123.456, [malt.defaultExtractPotential floatValue], 0.001);
  XCTAssertEqualObjects(@(OBMaltTypeSugar), malt.type);

  // Note: Lovibond is stored as an integer, so 78.9 is truncated to 78 by CoreData
  XCTAssertEqual(78.0, [malt.defaultLovibond floatValue]);
}

- (void)testIsGrain
{
  OBMalt *malt = [self createTestMalt];

  malt.type = @(OBMaltTypeGrain);
  XCTAssertTrue(malt.isGrain);

  malt.type = @(OBMaltTypeExtract);
  XCTAssertFalse(malt.isGrain);

  malt.type = @(OBMaltTypeSugar);
  XCTAssertFalse(malt.isGrain);
}

- (void)testIsSugar
{
  OBMalt *malt = [self createTestMalt];

  malt.type = @(OBMaltTypeGrain);
  XCTAssertFalse(malt.isSugar);

  malt.type = @(OBMaltTypeExtract);
  XCTAssertFalse(malt.isSugar);

  malt.type = @(OBMaltTypeSugar);
  XCTAssertTrue(malt.isSugar);
}

- (void)testIsExtract
{
  OBMalt *malt = [self createTestMalt];

  malt.type = @(OBMaltTypeGrain);
  XCTAssertFalse(malt.isExtract);

  malt.type = @(OBMaltTypeExtract);
  XCTAssertTrue(malt.isExtract);

  malt.type = @(OBMaltTypeSugar);
  XCTAssertFalse(malt.isExtract);
}

@end
