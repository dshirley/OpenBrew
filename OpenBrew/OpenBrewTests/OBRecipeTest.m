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

#define OBAssertOriginalGravity(og) XCTAssertEqualWithAccuracy([self.recipe originalGravity], og, 0.002);
#define OBAssertFinalGravity(fg) XCTAssertEqualWithAccuracy([self.recipe finalGravity], fg, 0.002);
#define OBAssertIBU(ibus) XCTAssertEqualWithAccuracy([self.recipe IBUs], ibus, 1);
#define OBAssertColorInSrm(colorSrm) XCTAssertEqualWithAccuracy([self.recipe colorInSRM], colorSrm, 1);

// Allow a greater degree of flexibility for ABV.  Brewing Classic Styles uses the
// simple formula ((og - fg) * 131.25), which comes out a bit lower.
#define OBAssertABV(abv) XCTAssertEqualWithAccuracy([self.recipe alcoholByVolume], abv, 0.5);

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
  [self addYeast:@"WLP840"];

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
  [self addYeast:@"WLP840"];

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
  [self addYeast:@"WLP840"];

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
  [self addHops:@"Hallertau" quantity:1.1 aaPercent:4.0 boilTime:90];
  [self addYeast:@"WLP838"];

  // 77% attenuation
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
  [self addMalt:@"Melanoidin Malt" quantity:0.25 color:28];
  [self addHops:@"Hallertau" quantity:1.1 aaPercent:4.0 boilTime:90];
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

- (void)testBrewingClassicStyles_GermanPilsner_Extract
{
  [self addMalt:@"Pilsner LME" quantity:8.2 color:2.3];
  [self addHops:@"Perle" quantity:1.0 aaPercent:8.0 boilTime:90];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:15];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:1];
  [self addYeast:@"WLP830"];

  OBAssertOriginalGravity(1.048);
  OBAssertFinalGravity(1.009);
  OBAssertIBU(36);
  OBAssertColorInSrm(3);
  OBAssertABV(5.1);
}

- (void)testBrewingClassicStyles_GermanPilsner_AllGrain
{
  [self addMalt:@"Pilsner Malt" quantity:10.8];
  [self addHops:@"Perle" quantity:1.0 aaPercent:8.0 boilTime:90];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:15];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:1];
  [self addYeast:@"WLP830"];

  OBAssertOriginalGravity(1.048);
  OBAssertFinalGravity(1.009);
  OBAssertIBU(36);
  OBAssertColorInSrm(3);
  OBAssertABV(5.1);
}

- (void)testBrewingClassicStyles_MunichDunkel_Extract
{
  [self addMalt:@"Munich LME" quantity:8.5 color:9];
  [self addMalt:@"Carafa II" quantity:(6.0/16) color:430];
  [self addHops:@"Hallertau" quantity:1.2 aaPercent:4.0 boilTime:60];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:20];
  [self addYeast:@"WLP833"];

  OBAssertOriginalGravity(1.054);
  OBAssertFinalGravity(1.014);
  OBAssertIBU(22);
  OBAssertColorInSrm(19);
  OBAssertABV(5.3);
}

- (void)testBrewingClassicStyles_MunichDunkel_AllGrain
{
  [self addMalt:@"Munich 10" quantity:12.2];
  [self addMalt:@"Carafa II" quantity:(6.0/16) color:430];
  [self addHops:@"Hallertau" quantity:1.2 aaPercent:4.0 boilTime:60];
  [self addHops:@"Hallertau" quantity:0.5 aaPercent:4.0 boilTime:20];
  [self addYeast:@"WLP833"];

  OBAssertOriginalGravity(1.054);
  OBAssertFinalGravity(1.014);
  OBAssertIBU(22);
  OBAssertColorInSrm(19);
  OBAssertABV(5.3);
}

- (void)testAddHopsDisplayOrder
{
  OBHops *testHops = [[OBHops alloc] initWithCatalog:self.brewery.ingredientCatalog
                                                name:@"test hops"
                                    alphaAcidPercent:@(8.0)];

  OBHopAddition *testHopAddition1 = [[OBHopAddition alloc] initWithHopVariety:testHops andRecipe:nil];
  OBHopAddition *testHopAddition2 = [[OBHopAddition alloc] initWithHopVariety:testHops andRecipe:nil];

  XCTAssertEqual([testHopAddition1.displayOrder integerValue], 0);
  XCTAssertEqual([testHopAddition2.displayOrder integerValue], 0);

  testHopAddition1.displayOrder = @(888);
  [self.recipe addHopAdditionsObject:testHopAddition1];
  XCTAssertEqual([testHopAddition1.displayOrder integerValue], 0);

  // The items are a set, so it shouldn't get added again, thus the display order won't change.
  XCTAssertEqual([testHopAddition1.displayOrder integerValue], 0);

  // Add the second hops, its display should get set to an incremental value based on the number of existing hops
  [self.recipe addHopAdditionsObject:testHopAddition2];
  XCTAssertEqual([testHopAddition2.displayOrder integerValue], 1);

  // Setting the recipe in the initializer has the affect of adding the malt to the recipe
  OBHopAddition *testHopAddition3 = [[OBHopAddition alloc] initWithHopVariety:testHops andRecipe:self.recipe];
  XCTAssertEqual([testHopAddition3.displayOrder integerValue], 2);
  
}

- (void)testAddMaltDisplayOrder
{
  OBMalt *testMalt = [[OBMalt alloc] initWithCatalog:self.brewery.ingredientCatalog
                                                name:@"test malt"
                                    extractPotential:@(0)
                                            lovibond:@(0)
                                                type:@(OBMaltTypeExtract)];

  OBMaltAddition *testMaltAddition1 = [[OBMaltAddition alloc] initWithMalt:testMalt andRecipe:nil];
  OBMaltAddition *testMaltAddition2 = [[OBMaltAddition alloc] initWithMalt:testMalt andRecipe:nil];

  XCTAssertEqual([testMaltAddition1.displayOrder integerValue], 0);
  XCTAssertEqual([testMaltAddition2.displayOrder integerValue], 0);

  testMaltAddition1.displayOrder = @(888);
  [self.recipe addMaltAdditionsObject:testMaltAddition1];
  XCTAssertEqual([testMaltAddition1.displayOrder integerValue], 0);

  // The items are a set, so it shouldn't get added again, thus the display order won't change.
  XCTAssertEqual([testMaltAddition1.displayOrder integerValue], 0);

  // Add the second malt, its display should get set to an incremental value based on the number of existing malts
  [self.recipe addMaltAdditionsObject:testMaltAddition2];
  XCTAssertEqual([testMaltAddition2.displayOrder integerValue], 1);

  // Setting the recipe in the initializer has the affect of adding the malt to the recipe
  OBMaltAddition *testMaltAddition3 = [[OBMaltAddition alloc] initWithMalt:testMalt andRecipe:self.recipe];
  XCTAssertEqual([testMaltAddition3.displayOrder integerValue], 2);

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
