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
  OBMalt *malt = [[OBMalt alloc] initWithCatalog:self.brewery.ingredientCatalog
                                            name:@"test malt"
                                extractPotential:@(0)
                                        lovibond:@(0)
                                            type:@(type)];

  return [[OBMaltAddition alloc] initWithMalt:malt andRecipe:nil];
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

@end
