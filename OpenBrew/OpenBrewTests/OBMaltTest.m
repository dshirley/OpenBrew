//
//  OBMaltTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/16/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBMalt.h"

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
  OBMalt *malt = [[OBMalt alloc]
                  initWithName:@"TestMalt"
                  andDescription:@""
                  andQuantity:5.25
                  andGravityUnits:37
                  andLovibond:0];

  XCTAssertEqualWithAccuracy(139.86, [malt contributedGravityUnitsWithEfficiency:.72], .01, @"");
  XCTAssertEqualWithAccuracy(194.25, [malt contributedGravityUnitsWithEfficiency:1], .01, @"");
  XCTAssertEqualWithAccuracy(0.0, [malt contributedGravityUnitsWithEfficiency:0], .01, @"");

  [malt setQuantityInPounds:1];
  XCTAssertEqualWithAccuracy(37.00, [malt contributedGravityUnitsWithEfficiency:1], .01, @"");
  XCTAssertEqualWithAccuracy(24.42, [malt contributedGravityUnitsWithEfficiency:.66], .01, @"");
}

@end
