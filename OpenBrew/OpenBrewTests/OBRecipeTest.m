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
#import "OBKvoUtils.h"

#define OBAssertOriginalGravity(og) XCTAssertEqualWithAccuracy([self.recipe originalGravity], og, 0.002);
#define OBAssertFinalGravity(fg) XCTAssertEqualWithAccuracy([self.recipe finalGravity], fg, 0.002);
#define OBAssertIBU(ibus) XCTAssertEqualWithAccuracy([self.recipe IBUs], ibus, 1);
#define OBAssertColorInSrm(colorSrm) XCTAssertEqualWithAccuracy([self.recipe colorInSRM], colorSrm, 1);

// Allow a greater degree of flexibility for ABV.  Brewing Classic Styles uses the
// simple formula ((og - fg) * 131.25), which comes out a bit lower.
#define OBAssertABV(abv) XCTAssertEqualWithAccuracy([self.recipe alcoholByVolume], abv, 0.5);

@interface OBRecipeTest : OBBaseTestCase
@property (nonatomic, strong) OBRecipe *recipe;

// For the KVO test
@property (nonatomic, strong) NSMutableDictionary *keysObserved;

@end

@implementation OBRecipeTest

- (void)setUp
{
  [super setUp];
  self.recipe = [[OBRecipe alloc] initWithContext:self.ctx];
  self.keysObserved = [NSMutableDictionary dictionary];

  // Most of the tests in this suite are based on recipes in Brewing Classic Styles.
  // The recipes in that book use the Rager formula.
  [OBSettings setIbuFormula:OBIbuFormulaRager];
}

- (void)tearDown
{
  self.recipe = nil;
}


#pragma mark Property Tests

// The setters for hopAdditions and maltAdditions were overriden.
// They're worth testing
- (void)testAddHops
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
  XCTAssertEqual(self.recipe.hopAdditions.count, 1);
  XCTAssertTrue([self.recipe.hopAdditions containsObject:testHopAddition1]);

  // The items are a set, so it shouldn't get added again, thus the display order won't change.
  XCTAssertEqual([testHopAddition1.displayOrder integerValue], 0);
  XCTAssertEqual(self.recipe.hopAdditions.count, 1);
  XCTAssertTrue([self.recipe.hopAdditions containsObject:testHopAddition1]);

  // Add the second hops, its display should get set to an incremental value based on the number of existing hops
  [self.recipe addHopAdditionsObject:testHopAddition2];
  XCTAssertEqual([testHopAddition2.displayOrder integerValue], 1);
  XCTAssertEqual(self.recipe.hopAdditions.count, 2);
  XCTAssertTrue([self.recipe.hopAdditions containsObject:testHopAddition1]);
  XCTAssertTrue([self.recipe.hopAdditions containsObject:testHopAddition2]);

  // Setting the recipe in the initializer has the affect of adding the malt to the recipe
  OBHopAddition *testHopAddition3 = [[OBHopAddition alloc] initWithHopVariety:testHops andRecipe:self.recipe];
  XCTAssertEqual([testHopAddition3.displayOrder integerValue], 2);
  XCTAssertEqual(self.recipe.hopAdditions.count, 3);
  XCTAssertTrue([self.recipe.hopAdditions containsObject:testHopAddition1]);
  XCTAssertTrue([self.recipe.hopAdditions containsObject:testHopAddition2]);
  XCTAssertTrue([self.recipe.hopAdditions containsObject:testHopAddition3]);
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

  XCTAssertEqual(self.recipe.maltAdditions.count, 0);

  testMaltAddition1.displayOrder = @(888);
  [self.recipe addMaltAdditionsObject:testMaltAddition1];
  XCTAssertEqual([testMaltAddition1.displayOrder integerValue], 0);
  XCTAssertEqual(self.recipe.maltAdditions.count, 1);
  XCTAssertTrue([self.recipe.maltAdditions containsObject:testMaltAddition1]);

  // The items are a set, so it shouldn't get added again, thus the display order won't change.
  XCTAssertEqual([testMaltAddition1.displayOrder integerValue], 0);
  XCTAssertEqual(self.recipe.maltAdditions.count, 1);
  XCTAssertTrue([self.recipe.maltAdditions containsObject:testMaltAddition1]);

  // Add the second malt, its display should get set to an incremental value based on the number of existing malts
  [self.recipe addMaltAdditionsObject:testMaltAddition2];
  XCTAssertEqual([testMaltAddition2.displayOrder integerValue], 1);
  XCTAssertEqual(self.recipe.maltAdditions.count, 2);
  XCTAssertTrue([self.recipe.maltAdditions containsObject:testMaltAddition1]);
  XCTAssertTrue([self.recipe.maltAdditions containsObject:testMaltAddition2]);

  // Setting the recipe in the initializer has the affect of adding the malt to the recipe
  OBMaltAddition *testMaltAddition3 = [[OBMaltAddition alloc] initWithMalt:testMalt andRecipe:self.recipe];
  XCTAssertEqual([testMaltAddition3.displayOrder integerValue], 2);
  XCTAssertEqual(self.recipe.maltAdditions.count, 3);
  XCTAssertTrue([self.recipe.maltAdditions containsObject:testMaltAddition1]);
  XCTAssertTrue([self.recipe.maltAdditions containsObject:testMaltAddition2]);
  XCTAssertTrue([self.recipe.maltAdditions containsObject:testMaltAddition3]);
}

#pragma mark KVO Tests

// When any of the key metrics of a recipe change. KVO should fire off for all
// of these keys. Even if only gravity changes, IBUs will still fire. This is
// intentional. It would be relatively error prone to tease out all of the variables that
// affect IBUs (it would be easy to miss something), and the performance cost
// of notifying for all of these keys simply isn't high enough to warrant the effort
// of making KVO more targetted.
- (void)checkAllCalculatedKeysSeen
{
  XCTAssertEqual(self.keysObserved[KVO_KEY(originalGravity)], self.recipe);
  XCTAssertEqual(self.keysObserved[KVO_KEY(IBUs)], self.recipe);
  XCTAssertEqual(self.keysObserved[KVO_KEY(boilGravity)], self.recipe);
  XCTAssertEqual(self.keysObserved[KVO_KEY(colorInSRM)], self.recipe);
  XCTAssertEqual(self.keysObserved[KVO_KEY(finalGravity)], self.recipe);
  XCTAssertEqual(self.keysObserved[KVO_KEY(alcoholByVolume)], self.recipe);
}

- (void)startObservingAllCalculatedKeys
{
  [self.recipe addObserver:self forKeyPath:KVO_KEY(originalGravity) options:0 context:nil];
  [self.recipe addObserver:self forKeyPath:KVO_KEY(IBUs) options:0 context:nil];
  [self.recipe addObserver:self forKeyPath:KVO_KEY(boilGravity) options:0 context:nil];
  [self.recipe addObserver:self forKeyPath:KVO_KEY(colorInSRM) options:0 context:nil];
  [self.recipe addObserver:self forKeyPath:KVO_KEY(finalGravity) options:0 context:nil];
  [self.recipe addObserver:self forKeyPath:KVO_KEY(alcoholByVolume) options:0 context:nil];
}

- (void)testMaltAdditionsKvo
{
  [self.recipe addObserver:self forKeyPath:KVO_KEY(maltAdditions) options:0 context:nil];
  [self addMalt:@"Munich 10" quantity:0];
  XCTAssertEqual(self.keysObserved[KVO_KEY(maltAdditions)], self.recipe);
}

- (void)testHopAdditionsKvo
{
  [self.recipe addObserver:self forKeyPath:KVO_KEY(hopAdditions) options:0 context:nil];
  [self addHops:@"Citra" quantity:3.0 aaPercent:5.0 boilTime:45];
  XCTAssertEqual(self.keysObserved[KVO_KEY(hopAdditions)], self.recipe);
}

- (void)testCalculatedKvo_AddingMaltsZeroQuantity
{
  [self startObservingAllCalculatedKeys];
  [self addMalt:@"Munich 10" quantity:0];
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_AddingMalts
{
  [self startObservingAllCalculatedKeys];
  [self addMalt:@"Munich 10" quantity:1.0];
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_AddingHops
{
  [self startObservingAllCalculatedKeys];
  [self addHops:@"Citra" quantity:1.0 aaPercent:13.0 boilTime:60];
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_AddingHopsZeroBoilTime
{
  [self startObservingAllCalculatedKeys];
  [self addHops:@"Citra" quantity:1.0 aaPercent:13.0 boilTime:0];
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_AddingHopsZeroQuantity
{
  [self startObservingAllCalculatedKeys];
  [self addHops:@"Citra" quantity:0 aaPercent:13.0 boilTime:0];
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_AddingHopsZeroAlphaAcids
{
  [self startObservingAllCalculatedKeys];
  [self addHops:@"Citra" quantity:0 aaPercent:0.0 boilTime:0];
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_AddYeast
{
  [self startObservingAllCalculatedKeys];
  [self addYeast:@"WLP833"];
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingMaltQuantity
{
  [self addMalt:@"Pilsner Malt" quantity:5.0];
  OBMaltAddition *maltAddition = [self.recipe.maltAdditions anyObject];

  [self startObservingAllCalculatedKeys];
  maltAddition.quantityInPounds = @(5.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingMaltQuantityToSameValue
{
  [self addMalt:@"Pilsner Malt" quantity:5.0];
  OBMaltAddition *maltAddition = [self.recipe.maltAdditions anyObject];
  maltAddition.quantityInPounds = @(5.0);

  [self startObservingAllCalculatedKeys];
  maltAddition.quantityInPounds = @(5.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingMaltColor
{
  [self addMalt:@"Pilsner Malt" quantity:5.0];
  OBMaltAddition *maltAddition = [self.recipe.maltAdditions anyObject];

  [self startObservingAllCalculatedKeys];
  maltAddition.quantityInPounds = @(7.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingMaltColorToSameValue
{
  [self addMalt:@"Pilsner Malt" quantity:5.0];
  OBMaltAddition *maltAddition = [self.recipe.maltAdditions anyObject];
  maltAddition.lovibond = @(7.0);

  [self startObservingAllCalculatedKeys];
  maltAddition.quantityInPounds = @(7.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingHopQuantity
{
  [self addHops:@"Hallertau" quantity:1.2 aaPercent:4.0 boilTime:60];

  OBHopAddition *hopAddition = [self.recipe.hopAdditions anyObject];

  [self startObservingAllCalculatedKeys];
  hopAddition.quantityInOunces = @(7.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingHopQuantityToSameValue
{
  [self addHops:@"Hallertau" quantity:1.2 aaPercent:4.0 boilTime:60];

  OBHopAddition *hopAddition = [self.recipe.hopAdditions anyObject];
  hopAddition.quantityInOunces = @(7.0);

  [self startObservingAllCalculatedKeys];
  hopAddition.quantityInOunces = @(7.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingHopAlphaAcidPercent
{
  [self addHops:@"Hallertau" quantity:1.2 aaPercent:4.0 boilTime:60];

  OBHopAddition *hopAddition = [self.recipe.hopAdditions anyObject];

  [self startObservingAllCalculatedKeys];
  hopAddition.alphaAcidPercent = @(7.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingHopAlphaAcidPercentToSameValue
{
  [self addHops:@"Hallertau" quantity:1.2 aaPercent:4.0 boilTime:60];

  OBHopAddition *hopAddition = [self.recipe.hopAdditions anyObject];
  hopAddition.alphaAcidPercent = @(7.0);

  [self startObservingAllCalculatedKeys];
  hopAddition.alphaAcidPercent = @(7.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingHopBoilTime
{
  [self addHops:@"Hallertau" quantity:1.2 aaPercent:4.0 boilTime:60];

  OBHopAddition *hopAddition = [self.recipe.hopAdditions anyObject];

  [self startObservingAllCalculatedKeys];
  hopAddition.boilTimeInMinutes = @(7.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_ChangingHopBoilTimeToSameValue
{
  [self addHops:@"Hallertau" quantity:1.2 aaPercent:4.0 boilTime:60];

  OBHopAddition *hopAddition = [self.recipe.hopAdditions anyObject];
  hopAddition.boilTimeInMinutes = @(7.0);

  [self startObservingAllCalculatedKeys];
  hopAddition.boilTimeInMinutes = @(7.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_SetPreBoilVolume
{
  [self startObservingAllCalculatedKeys];
  self.recipe.preBoilVolumeInGallons = @(8.0);
  [self checkAllCalculatedKeysSeen];
}

// This could probably be optimized pretty easily, but it is the current behavior and its pretty harmless
- (void)testCalculatedKvo_SetPreBoilVolumeTwiceWithSameValue
{
  self.recipe.preBoilVolumeInGallons = @(8.0);
  [self startObservingAllCalculatedKeys];
  self.recipe.preBoilVolumeInGallons = @(8.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)testCalculatedKvo_SetPostBoilVolume
{
  [self startObservingAllCalculatedKeys];
  self.recipe.postBoilVolumeInGallons = @(7.0);
  [self checkAllCalculatedKeysSeen];
}

// This could probably be optimized pretty easily, but it is the current behavior and its pretty harmless
- (void)testCalculatedKvo_SetPostBoilVolumeTwiceWithSameValue
{
  self.recipe.postBoilVolumeInGallons = @(8.0);
  [self startObservingAllCalculatedKeys];
  self.recipe.postBoilVolumeInGallons = @(8.0);
  [self checkAllCalculatedKeysSeen];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  self.keysObserved[keyPath] = object;
}

#pragma mark Brewing Classic Styles Recipe Tests

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

#pragma mark Recipe Building Helper Methods

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
