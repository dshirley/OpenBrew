//
//  OBRecipeTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBRecipe.h"
#import "OBMalt.h"
#import "OBMaltAddition.h"
#import "OBHops.h"
#import "OBHopAddition.h"
#import "OBYeast.h"
#import "OBYeastAddition.h"
#import "OBSettings.h"

#define OBAssertOriginalGravity(og) XCTAssertEqualWithAccuracy([self.recipe originalGravity], og, 0.001);
#define OBAssertFinalGravity(fg) XCTAssertEqualWithAccuracy([self.recipe finalGravity], fg, 0.001);
#define OBAssertIBU(ibus) XCTAssertEqualWithAccuracy([self.recipe IBUs], ibus, 1);
#define OBAssertColorInSrm(colorSrm) XCTAssertEqualWithAccuracy([self.recipe colorInSRM], colorSrm, 1);
#define OBAssertABV(abv) XCTAssertEqualWithAccuracy([self.recipe alcoholByVolume], abv, 0.2);

@interface OBRecipeTest : OBBaseTestCase
@property (nonatomic, strong) OBRecipe *recipe;
@end

@implementation OBRecipeTest

- (void)setUp
{
  [super setUp];
  self.recipe = [[OBRecipe alloc] initWithContext:self.ctx];

  // Most of the tests in this suite are based on recipes in Brewing Classic Styles.
  // The recipes in that book use the Rager formula.
  [OBSettings setIbuFormula:OBIbuFormulaRager];
}

- (void)testBrewingClassicStyles_LighAmericanLager_Extract
{
  [self addMalt:@"Light LME" quantity:5.0 color:2.2];
  [self addMalt:@"Rice Syrup" quantity:1.3 color:0];
  [self addHops:@"Hallertau" quantity:0.61 aaPercent:4.0 boilTime:60];
  [self addYeast:@"WLP840"];

  OBAssertOriginalGravity(1.038);
  OBAssertFinalGravity(1.007);
  OBAssertIBU(10);
  OBAssertColorInSrm(2.0);
  OBAssertABV(4.1);
}

- (void)testBrewingClassicStyles_LighAmericanLager_AllGrain
{
  [self addMalt:@"Two-Row" quantity:6.9];
  [self addMalt:@"Rice (flaked)" quantity:2.5];
  [self addHops:@"Hallertau" quantity:0.61 aaPercent:4.0 boilTime:60];
  [self addYeast:@"WLP840"];

  OBAssertOriginalGravity(1.038);
  OBAssertFinalGravity(1.007);
  OBAssertIBU(10);
  OBAssertColorInSrm(2.0);
  OBAssertABV(4.1);
}

- (void)testBrewingClassicStyles_StandardAmericanLager_Extract
{
  [self addMalt:@"Light LME" quantity:6.25 color:2.2];
  [self addMalt:@"Rice Syrup" quantity:1.5 color:0];
  [self addHops:@"Hallertau" quantity:0.72 aaPercent:4.0 boilTime:60];
  [self addYeast:@"2007"];

  OBAssertOriginalGravity(1.046);
  OBAssertFinalGravity(1.008);
  OBAssertIBU(12);
  OBAssertColorInSrm(3.0);
  OBAssertABV(5.0);
}

- (void)testBrewingClassicStyles_StandardAmericanLager_AllGrain
{
  [self addMalt:@"Two-Row" quantity:8.3];
  [self addMalt:@"Rice (flaked)" quantity:2.8];
  [self addHops:@"Hallertau" quantity:0.72 aaPercent:4.0 boilTime:60];
  [self addYeast:@"2007"];

  OBAssertOriginalGravity(1.046);
  OBAssertFinalGravity(1.008);
  OBAssertIBU(12);
  OBAssertColorInSrm(3.0);
  OBAssertABV(5.0);
}

- (void)testBrewingClassicStyles_PremiumAmericanLager_Extract
{
  [self addMalt:@"Light LME" quantity:8.0 color:2.2];
  [self addMalt:@"Rice Syrup" quantity:1.0 color:0];
  [self addHops:@"Hallertau" quantity:1.25 aaPercent:4.0 boilTime:60];
  [self addYeast:@"WLP840"];

  OBAssertOriginalGravity(1.053);
  OBAssertFinalGravity(1.010);
  OBAssertIBU(20);
  OBAssertColorInSrm(3.0);
  OBAssertABV(5.7);
}

- (void)testBrewingClassicStyles_PremiumAmericanLager_AllGrain
{
  [self addMalt:@"Two-Row" quantity:11.6];
  [self addMalt:@"Rice (flaked)" quantity:1.0];
  [self addHops:@"Hallertau" quantity:1.25 aaPercent:4.0 boilTime:60];
  [self addYeast:@"2007"];

  OBAssertOriginalGravity(1.053);
  OBAssertFinalGravity(1.010);
  OBAssertIBU(20);
  OBAssertColorInSrm(3.0);
  OBAssertABV(5.7);
}

- (void)testBrewingClassicStyles_MunichHelles_Extract
{
  [self addMalt:@"Pilsner LME" quantity:7.6 color:2.3];
  [self addMalt:@"Munich LME" quantity:0.5 color:9];
  [self addMalt:@"Melanoidin Malt" quantity:0.25 color:28];
  [self addHops:@"Hallertau" quantity:1.1 aaPercent:4.0 boilTime:60];
  [self addYeast:@"WLP838"];

  OBAssertOriginalGravity(1.048);
  OBAssertFinalGravity(1.011);
  OBAssertIBU(18);
  OBAssertColorInSrm(4);
  OBAssertABV(5.0);
}

- (void)testBrewingClassicStyles_MunichHelles_AllGrain
{
  [self addMalt:@"Pilsner Malt" quantity:10.5];
  [self addMalt:@"Munich 10" quantity:0.75];
//  [self addMalt:@"Melanoidin Malt" quantity:0.25 color:28];
  [self addHops:@"Hallertau" quantity:1.1 aaPercent:4.0 boilTime:60];
  [self addYeast:@"2308"];

  OBAssertOriginalGravity(1.048);
  OBAssertFinalGravity(1.011);
  OBAssertIBU(18);
  OBAssertColorInSrm(4);
  OBAssertABV(5.0);
}

- (void)testBrewingClassicStyles_DortmunderExport_Extract
{
  [self addMalt:@"Pilsner LME" quantity:6.4 color:2.3];
  [self addMalt:@"Munich LME" quantity:3.0 color:9];
  [self addMalt:@"Melanoidin Malt" quantity:.125 color:28];
  [self addHops:@"Hallertau" quantity:1.7 aaPercent:4.0 boilTime:60];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:5];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:0];
  [self addYeast:@"WLP830"];

  OBAssertOriginalGravity(1.055);
  OBAssertFinalGravity(1.013);
  OBAssertIBU(29);
  OBAssertColorInSrm(6);
  OBAssertABV(5.6);
}

- (void)testBrewingClassicStyles_DortmunderExport_AllGrain
{
  [self addMalt:@"Pilsner Malt" quantity:8.5];
  [self addMalt:@"Munich 10" quantity:4];
  [self addMalt:@"Melanoidin Malt" quantity:.125 color:28];
  [self addHops:@"Hallertau" quantity:1.7 aaPercent:4.0 boilTime:60];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:5];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:0];
  [self addYeast:@"WLP830"];

  OBAssertOriginalGravity(1.055);
  OBAssertFinalGravity(1.013);
  OBAssertIBU(29);
  OBAssertColorInSrm(6);
  OBAssertABV(5.6);
}

- (void)addMalt:(NSString *)maltName quantity:(float)quantity {
  [self addMalt:maltName quantity:quantity color:-1];
}

- (void)addMalt:(NSString *)maltName quantity:(float)quantity color:(float)color
{
  OBMalt *malt = [self fetchEntity:@"Malt" withProperty:@"name" equalTo:maltName];
  XCTAssertNotNil(malt);

  OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:malt andRecipe:self.recipe];
  maltAddition.quantityInPounds = @(quantity);

  if (color >= 0) {
    maltAddition.lovibond = @(color);
  }

  [self.recipe addMaltAdditionsObject:maltAddition];
}

- (void)addHops:(NSString *)hopsName quantity:(float)quantity aaPercent:(float)aaPercent boilTime:(float)boilTime
{
  OBHops *hops = [self fetchEntity:@"Hops" withProperty:@"name" equalTo:hopsName];
  XCTAssertNotNil(hops);

  OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:hops andRecipe:self.recipe];
  hopAddition.alphaAcidPercent = @(aaPercent);
  hopAddition.quantityInOunces = @(quantity);
  hopAddition.boilTimeInMinutes = @(boilTime);

  [self.recipe addHopAdditionsObject:hopAddition];
}

- (void)addYeast:(NSString *)identifier
{
  OBYeast *yeast = [self fetchEntity:@"Yeast" withProperty:@"identifier" equalTo:identifier];
  XCTAssertNotNil(yeast);

  OBYeastAddition *yeastAddition = [[OBYeastAddition alloc] initWithYeast:yeast andRecipe:self.recipe];
  self.recipe.yeast = yeastAddition;
}

@end
