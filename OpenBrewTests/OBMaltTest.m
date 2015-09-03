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
  return [[OBMalt alloc] initWithContext:self.ctx
                                    name:@"test malt"
                        extractPotential:@(0)
                                lovibond:@(0)
                                    type:@(OBMaltTypeExtract)];
}

// Test initializing with a grain, extract, and sugar from MaltCatalog.csv
- (void)testInitWithCatalogAndCsvData
{
  NSArray *csvData = @[ @"Pilsner Malt", @"1.036", @"2", @"0" ];
  OBMalt *malt = [[OBMalt alloc] initWithContext:self.ctx andCsvData:csvData];

  XCTAssertEqualObjects(@"Pilsner Malt", malt.name);
  XCTAssertEqualWithAccuracy(1.036, [malt.defaultExtractPotential floatValue], 0.00001);
  XCTAssertEqual(2, [malt.defaultLovibond integerValue]);
  XCTAssertEqualObjects(@(OBMaltTypeGrain), malt.type);

  csvData = @[ @"Rye LME", @"1.035", @"4", @"2" ];
  malt = [[OBMalt alloc] initWithContext:self.ctx andCsvData:csvData];

  XCTAssertEqualObjects(@"Rye LME", malt.name);
  XCTAssertEqualWithAccuracy(1.035, [malt.defaultExtractPotential floatValue], 0.00001);
  XCTAssertEqual(4, [malt.defaultLovibond integerValue]);
  XCTAssertEqualObjects(@(OBMaltTypeExtract), malt.type);


  csvData = @[ @"Brown Sugar (Dark)", @"1.046", @"50", @"1" ];
  malt = [[OBMalt alloc] initWithContext:self.ctx andCsvData:csvData];

  XCTAssertEqualObjects(@"Brown Sugar (Dark)", malt.name);
  XCTAssertEqualWithAccuracy(1.046, [malt.defaultExtractPotential floatValue], 0.00001);
  XCTAssertEqual(50, [malt.defaultLovibond integerValue]);
  XCTAssertEqualObjects(@(OBMaltTypeSugar), malt.type);
}

- (void)testInitWithCatalogNameExtractLovibondType
{
  OBMalt *malt = [[OBMalt alloc] initWithContext:self.ctx
                                            name:@"Slim Shady"
                                extractPotential:@(123.456)
                                        lovibond:@(78.9)
                                            type:@(OBMaltTypeSugar)];

  XCTAssertEqualObjects(@"Slim Shady", malt.name);
  XCTAssertEqualWithAccuracy(123.456, [malt.defaultExtractPotential floatValue], 0.001);
  XCTAssertEqualObjects(@(OBMaltTypeSugar), malt.type);

  // Note: Lovibond is stored as an integer, so 78.9 is truncated to 78 by CoreData
  XCTAssertEqual(78.0, [malt.defaultLovibond floatValue]);
}

@end
