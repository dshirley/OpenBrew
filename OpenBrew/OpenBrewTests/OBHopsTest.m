//
//  OBHopsTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/15/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBHops.h"


@interface OBHopsTest : XCTestCase

@end

@implementation OBHopsTest

#define EPSILON .001

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

- (void)testUtilizationForGravity
{
  // The only quantity that matters is boil time
  OBHops *hops = [[OBHops alloc]
                  initWithName:@"TestHop"
                  andDescription:@""
                  andAAPercent:0
                  andBoilTime:10
                  andQuantity:2];

  XCTAssertEqualWithAccuracy(0.100, [hops utilizationForGravity:1.030], EPSILON, @"");
  XCTAssertEqualWithAccuracy(0.070, [hops utilizationForGravity:1.070], EPSILON, @"");
  XCTAssertEqualWithAccuracy(0.045, [hops utilizationForGravity:1.120], EPSILON, @"");

  [hops setBoilTimeInMinutes:30];
  XCTAssertEqualWithAccuracy(0.194, [hops utilizationForGravity:1.040], EPSILON, @"");
  XCTAssertEqualWithAccuracy(0.162, [hops utilizationForGravity:1.060], EPSILON, @"");
  XCTAssertEqualWithAccuracy(0.135, [hops utilizationForGravity:1.080], EPSILON, @"");

  [hops setBoilTimeInMinutes:60];
  XCTAssertEqualWithAccuracy(0.231, [hops utilizationForGravity:1.050], EPSILON, @"");
  XCTAssertEqualWithAccuracy(0.193, [hops utilizationForGravity:1.070], EPSILON, @"");
  XCTAssertEqualWithAccuracy(0.161, [hops utilizationForGravity:1.090], EPSILON, @"");

}

- (void)testAlphaAcidUnits {
  // Easy math, but for sanity, use test examples from How To Brew
  // http://www.howtobrew.com/section1/chapter5-5.html
  // AAU (60) = 1.5 oz x 6.4 = 9.6 AAUs of Perle and AAU (15) = 1 oz x 4.6 = 4.6 AAUs of Liberty

  OBHops *hops = [[OBHops alloc]
                  initWithName:@"TestHop"
                  andDescription:@""
                  andAAPercent:6.4
                  andBoilTime:10
                  andQuantity:1.5];

  XCTAssertEqualWithAccuracy(9.6, [hops alphaAcidUnits], EPSILON, @"");

  [hops setAlphaAcidPercent:4.6];
  [hops setQuantityInOunces:1];
  XCTAssertEqualWithAccuracy(4.6, [hops alphaAcidUnits], EPSILON, @"");

  // Throw in a non-float, zero value
  [hops setAlphaAcidPercent:0];
  XCTAssertEqualWithAccuracy(0.0, [hops alphaAcidUnits], EPSILON, @"");

  [hops setQuantityInOunces:0.0];
  XCTAssertEqualWithAccuracy(0.0, [hops alphaAcidUnits], EPSILON, @"");

  [hops setAlphaAcidPercent:15.2];
  XCTAssertEqualWithAccuracy(0.0, [hops alphaAcidUnits], EPSILON, @"");

  [hops setQuantityInOunces:.66];
  XCTAssertEqualWithAccuracy(10.032, [hops alphaAcidUnits], EPSILON, @"");
}

- (void)testIbuContributionWithBoilSize {
  // Again, for sanity, use test examples from How To Brew
  // http://www.howtobrew.com/section1/chapter5-5.html

  OBHops *hops = [[OBHops alloc]
                  initWithName:@"TestHop"
                  andDescription:@""
                  andAAPercent:6.4
                  andBoilTime:60
                  andQuantity:1.5];

  XCTAssertEqualWithAccuracy(25, [hops ibuContributionWithBoilSize:5 andGravity:1.080], 1, @"");

  [hops setAlphaAcidPercent:4.6];
  [hops setQuantityInOunces:1];
  [hops setBoilTimeInMinutes:15];

  XCTAssertEqualWithAccuracy(6, [hops ibuContributionWithBoilSize:5 andGravity:1.080], 1, @"");
}

@end
