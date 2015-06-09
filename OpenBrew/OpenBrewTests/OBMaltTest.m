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

@interface OBMaltTest : XCTestCase

@end

@implementation OBMaltTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testContributedGravityUnitsWithEfficiency {
  OBMalt *malt = [[OBMalt alloc] init];

  OBMaltAddition *maltAddition = [[OBMaltAddition alloc] init];
                  
  [maltAddition setMalt:malt];
  [maltAddition setQuantityInPounds:@(5.25)];
  [maltAddition setExtractPotential:@(37)];

  XCTAssertEqualWithAccuracy(139.86, [maltAddition gravityUnitsWithEfficiency:.72], .01, @"");
  XCTAssertEqualWithAccuracy(194.25, [maltAddition gravityUnitsWithEfficiency:1], .01, @"");
  XCTAssertEqualWithAccuracy(0.0, [maltAddition gravityUnitsWithEfficiency:0], .01, @"");

  [maltAddition setQuantityInPounds:@(1)];
  XCTAssertEqualWithAccuracy(37.00, [maltAddition gravityUnitsWithEfficiency:1], .01, @"");
  XCTAssertEqualWithAccuracy(24.42, [maltAddition gravityUnitsWithEfficiency:.66], .01, @"");
}

@end
