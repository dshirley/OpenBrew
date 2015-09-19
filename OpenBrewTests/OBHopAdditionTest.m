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
  OBHops *hops = [[OBHops alloc] initWithContext:self.ctx
                                            name:@"test hops"
                                alphaAcidPercent:@(5.0)];

  return [[OBHopAddition alloc] initWithHopVariety:hops andRecipe:nil];
}

- (void)testInit
{
  OBHopAddition *hopAddition = [self createTestHopAddition];
  XCTAssertEqualObjects(@"test hops", hopAddition.name);
  XCTAssertEqualWithAccuracy(5.0, [hopAddition.alphaAcidPercent floatValue], 0.000001);
}

- (void)testInitWithHops
{
  OBHops *hops = [self fetchEntity:@"Hops" withProperty:@"name" equalTo:@"Eroica"];
  XCTAssertNotNil(hops);

  OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:hops andRecipe:self.recipe];

  NSArray *hopAttributes = hops.entity.attributesByName.allKeys;
  for (NSString *key in hopAttributes) {
    XCTAssertEqualObjects([hops valueForKey:key], [hopAddition valueForKey:key], @"key: %@", key);
  }

  XCTAssertEqualWithAccuracy(0, [hopAddition.quantityInOunces floatValue], 0.00001);
  XCTAssertEqual(self.recipe, hopAddition.recipe);
}

- (void)testTinsethUtilizationForGravity
{
  OBHopAddition *hopAddition = [self createTestHopAddition];
  hopAddition.quantityInOunces = @(2);
  hopAddition.boilTimeInMinutes = @(10);

  XCTAssertEqualWithAccuracy(0.100, [hopAddition tinsethUtilizationForGravity:1.030], EPSILON);
  XCTAssertEqualWithAccuracy(0.070, [hopAddition tinsethUtilizationForGravity:1.070], EPSILON);
  XCTAssertEqualWithAccuracy(0.045, [hopAddition tinsethUtilizationForGravity:1.120], EPSILON);

  hopAddition.boilTimeInMinutes = @(30);
  XCTAssertEqualWithAccuracy(0.194, [hopAddition tinsethUtilizationForGravity:1.040], EPSILON);
  XCTAssertEqualWithAccuracy(0.162, [hopAddition tinsethUtilizationForGravity:1.060], EPSILON);
  XCTAssertEqualWithAccuracy(0.135, [hopAddition tinsethUtilizationForGravity:1.080], EPSILON);

  hopAddition.boilTimeInMinutes = @(60);
  XCTAssertEqualWithAccuracy(0.231, [hopAddition tinsethUtilizationForGravity:1.050], EPSILON);
  XCTAssertEqualWithAccuracy(0.193, [hopAddition tinsethUtilizationForGravity:1.070], EPSILON);
  XCTAssertEqualWithAccuracy(0.161, [hopAddition tinsethUtilizationForGravity:1.090], EPSILON);
}

// Test values match the table at this URL: http://rhbc.co/wiki/calculating-ibus
- (void)testRagerUtilization
{
  OBHopAddition *hopAddition = [self createTestHopAddition];
  hopAddition.boilTimeInMinutes = @(3);

  XCTAssertEqualWithAccuracy([hopAddition ragerUtilization], .050, 1);

  hopAddition.boilTimeInMinutes = @(8);
  XCTAssertEqualWithAccuracy([hopAddition ragerUtilization], .060, 1);

  hopAddition.boilTimeInMinutes = @(13);
  XCTAssertEqualWithAccuracy([hopAddition ragerUtilization], .080, 1);

  hopAddition.boilTimeInMinutes = @(18);
  XCTAssertEqualWithAccuracy([hopAddition ragerUtilization], .101, 1);

  hopAddition.boilTimeInMinutes = @(23);
  XCTAssertEqualWithAccuracy([hopAddition ragerUtilization], .121, 1);

  hopAddition.boilTimeInMinutes = @(28);
  XCTAssertEqualWithAccuracy([hopAddition ragerUtilization], .153, 1);

  hopAddition.boilTimeInMinutes = @(33);
  XCTAssertEqualWithAccuracy([hopAddition ragerUtilization], .188, 1);

  hopAddition.boilTimeInMinutes = @(38);
  XCTAssertEqualWithAccuracy([hopAddition ragerUtilization], .228, 1);

  hopAddition.boilTimeInMinutes = @(43);
  XCTAssertEqualWithAccuracy([hopAddition ragerUtilization], .269, 1);
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

- (void)testIbusTinseth {
  // Again, for sanity, use test examples from How To Brew
  // http://www.howtobrew.com/section1/chapter5-5.html

  OBHopAddition *hopAddition = [self createTestHopAddition];
  hopAddition.alphaAcidPercent = @(6.4);
  hopAddition.boilTimeInMinutes = @(60);
  hopAddition.quantityInOunces = @(1.5);

  XCTAssertEqualWithAccuracy(25, [hopAddition ibusForRecipeVolume:5 boilGravity:1.080 ibuFormula:OBIbuFormulaTinseth], 0.5);

  hopAddition.alphaAcidPercent = @(4.6);
  hopAddition.quantityInOunces = @(1);
  hopAddition.boilTimeInMinutes = @(15);

  XCTAssertEqualWithAccuracy(6, [hopAddition ibusForRecipeVolume:5 boilGravity:1.080 ibuFormula:OBIbuFormulaTinseth], 0.5);
}

- (void)testIbusRager {
  // Based on some calculations for a German Pilsner in Brewing Classic Styles
  OBHopAddition *hopAddition = [self createTestHopAddition];

  hopAddition.alphaAcidPercent = @(8.0);
  hopAddition.boilTimeInMinutes = @(60);
  hopAddition.quantityInOunces = @(1.0);

  // Though after scrutinizing the formula for an hour, it turns out that BCS is slightly wrong (off by 2).
  // Maybe there was a typo in the book. I ended up adjusting the assertion to fit my manually calculated value.
  XCTAssertEqualWithAccuracy([hopAddition ibusForRecipeVolume:6 boilGravity:1.041 ibuFormula:OBIbuFormulaRager], 30.8, 0.5);

  hopAddition.alphaAcidPercent = @(4.0);
  hopAddition.boilTimeInMinutes = @(15);
  hopAddition.quantityInOunces = @(0.5);
  XCTAssertEqualWithAccuracy([hopAddition ibusForRecipeVolume:6 boilGravity:1.041 ibuFormula:OBIbuFormulaRager], 2.2, 0.5);

  hopAddition.alphaAcidPercent = @(4.0);
  hopAddition.boilTimeInMinutes = @(60);
  hopAddition.quantityInOunces = @(2.42);
  XCTAssertEqualWithAccuracy([hopAddition ibusForRecipeVolume:6 boilGravity:1.087 ibuFormula:OBIbuFormulaRager], 31.4, 0.5);
}

- (void)testQuantityInGrams
{
  OBHopAddition *hopAddition = [self createTestHopAddition];

  hopAddition.quantityInOunces = @(1.0);
  XCTAssertEqualWithAccuracy(28.0, [hopAddition.quantityInGrams floatValue], 0.000001);

  hopAddition.quantityInOunces = @(1.5);
  XCTAssertEqualWithAccuracy(42.0, [hopAddition.quantityInGrams floatValue], 0.000001);
}

- (void)testSetQuantityInGrams
{
  OBHopAddition *hopAddition = [self createTestHopAddition];

  hopAddition.quantityInGrams = @(28.0);
  XCTAssertEqualWithAccuracy(1.0, [hopAddition.quantityInOunces floatValue], 0.000001);

  hopAddition.quantityInGrams = @(42.0);
  XCTAssertEqualWithAccuracy(1.5, [hopAddition.quantityInOunces floatValue], 0.000001);
}

@end
