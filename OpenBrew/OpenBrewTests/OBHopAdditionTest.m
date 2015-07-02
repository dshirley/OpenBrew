//
//  OBHopsTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/15/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBHops.h"
#import "OBHopAddition.h"
#import "OBBaseTestCase.h"

@interface OBHopAdditionTest : OBBaseTestCase

@end

@implementation OBHopAdditionTest

#define EPSILON .001

- (OBHopAddition *)createTestHopAddition {
  OBHops *hops = [[OBHops alloc] initWithCatalog:self.brewery.ingredientCatalog
                                            name:@"test hops"
                                alphaAcidPercent:@(5.0)];

  return [[OBHopAddition alloc] initWithHopVariety:hops andRecipe:nil];
}


- (void)testUtilizationForGravity
{
  OBHopAddition *hopAddition = [self createTestHopAddition];
  hopAddition.quantityInOunces = @(2);
  hopAddition.boilTimeInMinutes = @(10);

  XCTAssertEqualWithAccuracy(0.100, [hopAddition utilizationForGravity:1.030], EPSILON);
  XCTAssertEqualWithAccuracy(0.070, [hopAddition utilizationForGravity:1.070], EPSILON);
  XCTAssertEqualWithAccuracy(0.045, [hopAddition utilizationForGravity:1.120], EPSILON);

  hopAddition.boilTimeInMinutes = @(30);
  XCTAssertEqualWithAccuracy(0.194, [hopAddition utilizationForGravity:1.040], EPSILON);
  XCTAssertEqualWithAccuracy(0.162, [hopAddition utilizationForGravity:1.060], EPSILON);
  XCTAssertEqualWithAccuracy(0.135, [hopAddition utilizationForGravity:1.080], EPSILON);

  hopAddition.boilTimeInMinutes = @(60);
  XCTAssertEqualWithAccuracy(0.231, [hopAddition utilizationForGravity:1.050], EPSILON);
  XCTAssertEqualWithAccuracy(0.193, [hopAddition utilizationForGravity:1.070], EPSILON);
  XCTAssertEqualWithAccuracy(0.161, [hopAddition utilizationForGravity:1.090], EPSILON);

}

- (void)testAlphaAcidUnits {
  // Easy math, but for sanity, use test examples from How To Brew
  // http://www.howtobrew.com/section1/chapter5-5.html
  // AAU (60) = 1.5 oz x 6.4 = 9.6 AAUs of Perle and AAU (15) = 1 oz x 4.6 = 4.6 AAUs of Liberty

  OBHopAddition *hopAddition = [self createTestHopAddition];

  hopAddition.alphaAcidPercent = @(6.4);
  hopAddition.quantityInOunces = @(1.5);
  XCTAssertEqualWithAccuracy(9.6, [hopAddition alphaAcidUnits], EPSILON);

  hopAddition.alphaAcidPercent = @(4.6);
  hopAddition.quantityInOunces = @(1);
  XCTAssertEqualWithAccuracy(4.6, [hopAddition alphaAcidUnits], EPSILON);

  // Throw in a non-float, zero value
  hopAddition.alphaAcidPercent = @(0);
  XCTAssertEqualWithAccuracy(0.0, [hopAddition alphaAcidUnits], EPSILON);

  hopAddition.quantityInOunces = @(0.0);
  XCTAssertEqualWithAccuracy(0.0, [hopAddition alphaAcidUnits], EPSILON);

  hopAddition.alphaAcidPercent = @(15.2);
  XCTAssertEqualWithAccuracy(0.0, [hopAddition alphaAcidUnits], EPSILON);

  hopAddition.quantityInOunces = @(.66);
  XCTAssertEqualWithAccuracy(10.032, [hopAddition alphaAcidUnits], EPSILON);
}

- (void)testIbuContributionWithBoilSize {
  // Again, for sanity, use test examples from How To Brew
  // http://www.howtobrew.com/section1/chapter5-5.html

  OBHopAddition *hopAddition = [self createTestHopAddition];
  hopAddition.alphaAcidPercent = @(6.4);
  hopAddition.boilTimeInMinutes = @(60);
  hopAddition.quantityInOunces = @(1.5);

  XCTAssertEqualWithAccuracy(25, [hopAddition ibuContributionWithBoilSize:5 andGravity:1.080], 0.5);

  hopAddition.alphaAcidPercent = @(4.6);
  hopAddition.quantityInOunces = @(1);
  hopAddition.boilTimeInMinutes = @(15);

  XCTAssertEqualWithAccuracy(6, [hopAddition ibuContributionWithBoilSize:5 andGravity:1.080], 0.5);
}

@end
