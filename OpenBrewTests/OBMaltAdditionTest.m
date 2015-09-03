//
//  OBMaltTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/16/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBMalt.h"
#import "OBMaltAddition.h"
#import "OBBaseTestCase.h"

@interface OBMaltAdditionTest : OBBaseTestCase

@end

@implementation OBMaltAdditionTest

- (OBMaltAddition *)createTestMaltAdditionWithMaltType:(OBMaltType)type {
  OBMalt *malt = [[OBMalt alloc] initWithContext:self.ctx
                                            name:@"test malt"
                                extractPotential:@(0)
                                        lovibond:@(0)
                                            type:@(type)];

  return [[OBMaltAddition alloc] initWithMalt:malt andRecipe:nil];
}

- (void)testName
{
  OBMaltAddition *maltAddition = [self createTestMaltAdditionWithMaltType:OBMaltTypeGrain];
  XCTAssertEqualObjects(@"test malt", maltAddition.name);
}

- (void)testType
{
  OBMaltAddition *maltAddition = [self createTestMaltAdditionWithMaltType:OBMaltTypeGrain];
  XCTAssertEqualObjects(@(0), [maltAddition type]);

  maltAddition = [self createTestMaltAdditionWithMaltType:OBMaltTypeSugar];
  XCTAssertEqualObjects(@(1), [maltAddition type]);

  maltAddition = [self createTestMaltAdditionWithMaltType:OBMaltTypeExtract];
  XCTAssertEqualObjects(@(2), [maltAddition type]);
}

- (void)testQuantityText
{
  OBMaltAddition *maltAddition = [self createTestMaltAdditionWithMaltType:OBMaltTypeGrain];

  maltAddition.quantityInPounds = @(0.25);
  XCTAssertEqualObjects(@"4oz", [maltAddition quantityText]);

  maltAddition.quantityInPounds = @(1.5);
  XCTAssertEqualObjects(@"1lb 8oz", [maltAddition quantityText]);

  maltAddition.quantityInPounds = @(8);
  XCTAssertEqualObjects(@"8lb", [maltAddition quantityText]);

  maltAddition.quantityInPounds = @(((1.0 / 16.0) / 8.0));
  XCTAssertEqualObjects(@"0.125oz", [maltAddition quantityText]);

  maltAddition.quantityInPounds = @((1.0 / 16.0) / 1001);
  XCTAssertEqualObjects(@"0lb", [maltAddition quantityText]);

  // 2oz + 1/8oz should round down to 2oz
  maltAddition.quantityInPounds = @(1.125 + ((1.0 / 16.0) / 8.0));
  XCTAssertEqualObjects(@"1lb 2oz", [maltAddition quantityText]);
}

- (void)testContributedGravityUnitsWithEfficiency {
  OBMaltAddition *maltAddition = [self createTestMaltAdditionWithMaltType:OBMaltTypeGrain];
                  
  [maltAddition setQuantityInPounds:@(5.25)];
  [maltAddition setExtractPotential:@(1.037)];

  XCTAssertEqualWithAccuracy(139.86, [maltAddition gravityUnitsWithEfficiency:.72], .01, @"");
  XCTAssertEqualWithAccuracy(194.25, [maltAddition gravityUnitsWithEfficiency:1], .01, @"");
  XCTAssertEqualWithAccuracy(0.0, [maltAddition gravityUnitsWithEfficiency:0], .01, @"");

  [maltAddition setQuantityInPounds:@(1)];
  XCTAssertEqualWithAccuracy(37.00, [maltAddition gravityUnitsWithEfficiency:1], .01, @"");
  XCTAssertEqualWithAccuracy(24.42, [maltAddition gravityUnitsWithEfficiency:.66], .01, @"");
}

- (void)testContributedGravityUnitsWithEfficiencyForSugars {
  OBMaltAddition *maltAddition = [self createTestMaltAdditionWithMaltType:OBMaltTypeSugar];

  [maltAddition setQuantityInPounds:@(1)];
  [maltAddition setExtractPotential:@(1.037)];
  XCTAssertEqualWithAccuracy(37.00, [maltAddition gravityUnitsWithEfficiency:1], .01, @"");
  XCTAssertEqualWithAccuracy(37.00, [maltAddition gravityUnitsWithEfficiency:.66], .01, @"");
}

- (void)testContributedGravityUnitsWithEfficiencyForExtracts {
  OBMaltAddition *maltAddition = [self createTestMaltAdditionWithMaltType:OBMaltTypeExtract];

  [maltAddition setQuantityInPounds:@(1)];
  [maltAddition setExtractPotential:@(1.037)];
  XCTAssertEqualWithAccuracy(37.00, [maltAddition gravityUnitsWithEfficiency:1], .01, @"");
  XCTAssertEqualWithAccuracy(37.00, [maltAddition gravityUnitsWithEfficiency:.66], .01, @"");
}

- (void)testIsGrain
{
  OBMaltAddition *malt = [self createTestMaltAdditionWithMaltType:OBMaltTypeGrain];

  malt.type = @(OBMaltTypeGrain);
  XCTAssertTrue(malt.isGrain);

  malt.type = @(OBMaltTypeExtract);
  XCTAssertFalse(malt.isGrain);

  malt.type = @(OBMaltTypeSugar);
  XCTAssertFalse(malt.isGrain);
}

- (void)testIsSugar
{
  OBMaltAddition *malt = [self createTestMaltAdditionWithMaltType:OBMaltTypeGrain];

  malt.type = @(OBMaltTypeGrain);
  XCTAssertFalse(malt.isSugar);

  malt.type = @(OBMaltTypeExtract);
  XCTAssertFalse(malt.isSugar);

  malt.type = @(OBMaltTypeSugar);
  XCTAssertTrue(malt.isSugar);
}

- (void)testIsExtract
{
  OBMaltAddition *malt = [self createTestMaltAdditionWithMaltType:OBMaltTypeGrain];

  malt.type = @(OBMaltTypeGrain);
  XCTAssertFalse(malt.isExtract);

  malt.type = @(OBMaltTypeExtract);
  XCTAssertTrue(malt.isExtract);

  malt.type = @(OBMaltTypeSugar);
  XCTAssertFalse(malt.isExtract);
}


@end
