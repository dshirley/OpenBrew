//
//  OBRecipe.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipe.h"
#import "OBSettings.h"
#import "OBHopAddition.h"
#import "OBMaltAddition.h"
#import "OBYeastAddition.h"
#import "OBYeast.h"
#import "OBKvoUtils.h"
#import "OBMalt.h"

NSString * const calculatedKVOKeys[] = {
  @"IBUs",
  @"originalGravity",
  @"boilGravity",
  @"colorInSRM",
  @"finalGravity",
  @"alcoholByVolume",
};

#define NUM_CALCULATED_KVO_KEYS (sizeof(calculatedKVOKeys) / sizeof(NSString *))

@interface OBRecipe()
@property (nonatomic) NSSet *observedHopVariables;
@property (nonatomic) NSSet *observedMaltVariables;
@property (nonatomic) NSSet *observedRecipeVariables;
@end

@interface OBRecipe(PrimitiveAccessors)

- (NSMutableSet *)primitiveHopAdditions;
- (NSMutableSet *)primitiveMaltAdditions;

@end

@implementation OBRecipe

@synthesize observedHopVariables;
@synthesize observedMaltVariables;
@synthesize observedRecipeVariables;

@dynamic preBoilVolumeInGallons;
@dynamic postBoilVolumeInGallons;
@dynamic name;
@dynamic settings;
@dynamic hopAdditions;
@dynamic maltAdditions;
@dynamic yeast;
@dynamic mashEfficiency;

- (id)initWithContext:(NSManagedObjectContext *)context
{
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Recipe"
                                          inManagedObjectContext:context];

  self = [self initWithEntity:desc insertIntoManagedObjectContext:context];

  if (self) {
    [self startObserving];
  }

  return self;
}

- (void)awakeFromFetch
{
  [self startObserving];
}

- (void)willTurnIntoFault
{
  [self stopObserving];
}

- (float)gravityUnits {
  float gravityUnits = 0.0;
  float efficiency = [self.mashEfficiency floatValue];

  for (OBMaltAddition *malt in [self maltAdditions]) {
    gravityUnits += [malt gravityUnitsWithEfficiency:efficiency];
  }

  return gravityUnits;
}

- (NSInteger)percentTotalGravityOfMaltAddition:(OBMaltAddition *)maltAddition
{
  assert([self.maltAdditions containsObject:maltAddition]);

  float gravityUnits = [self gravityUnits];
  float maltGravityUnits = [maltAddition gravityUnitsWithEfficiency:[self.mashEfficiency floatValue]];

  NSInteger percentOfTotal = 0;
  if (gravityUnits > 0) {
    percentOfTotal = roundf(100.0 * maltGravityUnits / gravityUnits);
  }

  return percentOfTotal;
}

- (float)ibusForHopAddition:(OBHopAddition *)hopAddition ibuFormula:(OBIbuFormula)ibuFormula;
{
  assert([self.hopAdditions containsObject:hopAddition]);

  float recipeVolume = [self.postBoilVolumeInGallons floatValue];
  float boilGravity = [self boilGravity];

  return [hopAddition ibusForRecipeVolume:recipeVolume
                              boilGravity:boilGravity
                               ibuFormula:ibuFormula];
}

- (float)originalGravity {
  float gravityUnits = [self gravityUnits];
  float wortVolumeAfterBoil = [self.postBoilVolumeInGallons floatValue];

  return 1 + (gravityUnits / wortVolumeAfterBoil / 1000);
}

- (float)finalGravity {
  float attenuationLevel = [self.yeast estimatedAttenuationAsDecimal];
  float wortVolumeAfterBoil = [self.postBoilVolumeInGallons floatValue];
  float finalGravityUnits = 0;

  for (OBMaltAddition *maltAddition in self.maltAdditions) {
    if ([maltAddition isSugar]) {
      // Sugars attenuate to zero.
      continue;
    }

    float gravityUnits = [maltAddition gravityUnitsWithEfficiency:[self.mashEfficiency floatValue]];
    finalGravityUnits += gravityUnits * (1 - attenuationLevel);
  }

  return 1 + (finalGravityUnits / wortVolumeAfterBoil / 1000);
}

- (float)boilGravity {
  float gravityUnits = [self gravityUnits];
  float boilSize = [self.preBoilVolumeInGallons floatValue];

  return 1 + (gravityUnits / boilSize / 1000);
}

- (float)IBUs:(OBIbuFormula)ibuFormula;
{
  float ibus = 0.0;
  float wortVolumeAfterBoil = [self.postBoilVolumeInGallons floatValue];
  float boilGravity = [self boilGravity];

  for (OBHopAddition *hops in [self hopAdditions]) {
    ibus += [hops ibusForRecipeVolume:wortVolumeAfterBoil
                                   boilGravity:boilGravity
                           ibuFormula:ibuFormula];
  }

  return ibus;
}

// Using the Morey equation: http://brewwiki.com/index.php/Estimating_Color
// SRM_Color = 1.4922 * [MCU ^ 0.6859] -- Good for beer colors < 50 SRM
- (float)colorInSRM
{
  float maltColorUnits = 0.0;

  for (OBMaltAddition *malt in [self maltAdditions]) {
    maltColorUnits += [malt maltColorUnitsForBoilSize:[self.preBoilVolumeInGallons floatValue]];
  }

  return 1.4922 * powf(maltColorUnits, 0.6859);
}

- (float)alcoholByVolume
{
  float og = [self originalGravity];
  float fg = [self finalGravity];
  return (76.08 * (og - fg) / (1.775 - og)) * (fg / 0.794);
}

- (float)bitternessToGravityRatio:(OBIbuFormula)ibuFormula;
{
  float nonDecimalGravity = 1000.0 * ([self originalGravity] - 1);
  float ibu = [self IBUs:ibuFormula];

  if (nonDecimalGravity == 0) {
    return INFINITY;
  }

  return ibu / nonDecimalGravity;
}

#pragma mark - Sorted Accessors

- (NSArray *)maltAdditionsSorted
{
  NSSortDescriptor *sortByDisplayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder"
                                                                     ascending:YES];

  NSArray *sortSpecification = @[ sortByDisplayOrder ];

  return [self.maltAdditions sortedArrayUsingDescriptors:sortSpecification];
}

- (NSArray *)hopAdditionsSorted
{
  NSSortDescriptor *sortByDisplayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder"
                                                                     ascending:YES];

  NSArray *sortSpecification = @[ sortByDisplayOrder ];

  return [self.hopAdditions sortedArrayUsingDescriptors:sortSpecification];
}

#pragma mark - KVO Related Methods

- (void)initializeVariableLists
{
  self.observedHopVariables = [NSSet setWithObjects:
                               KVO_KEY(alphaAcidPercent),
                               KVO_KEY(boilTimeInMinutes),
                               KVO_KEY(quantityInOunces), nil];

  self.observedMaltVariables = [NSSet setWithObjects:
                                KVO_KEY(quantityInPounds),
                                KVO_KEY(lovibond), nil];

  self.observedRecipeVariables = [NSSet setWithObjects:
                                  KVO_KEY(mashEfficiency),
                                  KVO_KEY(preBoilVolumeInGallons),
                                  KVO_KEY(postBoilVolumeInGallons),
                                  KVO_KEY(yeast), nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([self.observedMaltVariables containsObject:keyPath] ||
      [self.observedHopVariables containsObject:keyPath] ||
      [self.observedRecipeVariables containsObject:keyPath])
  {
    [self notifyCalculatedValuesChanged];
  } else {
    [NSException raise:@"Unrecognized Key" format:@"Key: %@", keyPath];
  }
}

// This method is a big KVO hammer. Instead of trying to tease out exactly which
// calculations have been changed, we assume all of them change.  Most calculations
// include many variables, and it isn't worth nitpicking through the code to
// create a more targetted KVO notification method.
- (void)notifyCalculatedValuesChanged
{
  for (int i = 0; i < NUM_CALCULATED_KVO_KEYS; i++) {
    [self willChangeValueForKey:calculatedKVOKeys[i]];
    [self didChangeValueForKey:calculatedKVOKeys[i]];
  }
}

- (void)notifyCalculatedValuesDeletingObjects:(NSSet *)changedObjects
{
  for (int i = 0; i < NUM_CALCULATED_KVO_KEYS; i++) {
    [self willChangeValueForKey:calculatedKVOKeys[i]
                withSetMutation:NSKeyValueMinusSetMutation
                   usingObjects:changedObjects];

    [self didChangeValueForKey:calculatedKVOKeys[i]
               withSetMutation:NSKeyValueMinusSetMutation
                  usingObjects:changedObjects];
  }
}

- (void)notifyCalculatedValuesInsertingObjects:(NSSet *)changedObjects
{
  for (int i = 0; i < NUM_CALCULATED_KVO_KEYS; i++) {
    [self willChangeValueForKey:calculatedKVOKeys[i]
                withSetMutation:NSKeyValueUnionSetMutation
                   usingObjects:changedObjects];

    [self didChangeValueForKey:calculatedKVOKeys[i]
               withSetMutation:NSKeyValueUnionSetMutation
                  usingObjects:changedObjects];
  }
}

- (void)startObservingKeys:(NSSet *)keys ofObject:(id)object
{
  for (NSString *key in keys) {
    [object addObserver:self forKeyPath:key options:0 context:nil];
  }
}

- (void)stopObservingKeys:(NSSet *)keys ofObject:(id)object
{
  for (NSString *key in keys) {
    [object removeObserver:self forKeyPath:key];
  }
}

// Our goal is to provide KVO for calculated values of this object. That is accomplished
// by observing for changes in the attributes of each malt addition and hop addition.
// Because this recipe could already contain malt & hop additions when it is instantiated
// (ie. if this recipe was saved in a previous session), then we need to go through
// the existing malts & hops and start observing them.  We also need add observers
// as new malts and hops get added to the mix, which is why we override "addHopAdditionsObject"
// and "addMaltAdditionsObject"
- (void)startObserving
{
  [self initializeVariableLists];
  for (OBHopAddition *hopAddition in self.hopAdditions) {
    [self startObservingKeys:self.observedHopVariables ofObject:hopAddition];
  }

  for (OBMaltAddition *maltAddition in self.maltAdditions) {
    [self startObservingKeys:self.observedMaltVariables ofObject:maltAddition];
  }

  [self startObservingKeys:self.observedRecipeVariables ofObject:self];
}

- (void)stopObserving
{
  for (OBHopAddition *hopAddition in self.hopAdditions) {
    [self stopObservingKeys:self.observedHopVariables ofObject:hopAddition];
  }

  for (OBMaltAddition *maltAddition in self.maltAdditions) {
    [self stopObservingKeys:self.observedMaltVariables ofObject:maltAddition];
  }

  [self stopObservingKeys:self.observedRecipeVariables ofObject:self];
}

#pragma mark - Hop Addition Properties

- (void)addHopAdditionsObject:(OBHopAddition *)value
{
  NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];


  [self willChangeValueForKey:KVO_KEY(hopAdditions)
              withSetMutation:NSKeyValueUnionSetMutation
                 usingObjects:changedObjects];

  if (![[self primitiveHopAdditions] containsObject:value]) {
    value.displayOrder = @(self.hopAdditions.count);
    [self startObservingKeys:self.observedHopVariables ofObject:value];
  }

  [[self primitiveHopAdditions] addObject:value];

  [self didChangeValueForKey:KVO_KEY(hopAdditions)
             withSetMutation:NSKeyValueUnionSetMutation
                usingObjects:changedObjects];

  [self notifyCalculatedValuesInsertingObjects:changedObjects];
}

- (void)removeHopAdditionsObject:(OBHopAddition *)value
{
  NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

  if ([[self primitiveHopAdditions] containsObject:value]) {
    [self stopObservingKeys:self.observedHopVariables ofObject:value];
  }

  [self willChangeValueForKey:KVO_KEY(hopAdditions)
              withSetMutation:NSKeyValueMinusSetMutation
                 usingObjects:changedObjects];

  [[self primitiveHopAdditions] removeObject:value];

  [self didChangeValueForKey:KVO_KEY(hopAdditions)
             withSetMutation:NSKeyValueMinusSetMutation
                usingObjects:changedObjects];

  [self notifyCalculatedValuesDeletingObjects:changedObjects];
}

#pragma mark - Malt Addition Properties

- (void)addMaltAdditionsObject:(OBMaltAddition *)value
{
  NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

  [self willChangeValueForKey:KVO_KEY(maltAdditions)
              withSetMutation:NSKeyValueUnionSetMutation
                 usingObjects:changedObjects];

  if (![[self primitiveMaltAdditions] containsObject:value]) {
    value.displayOrder = @(self.maltAdditions.count);
    [self startObservingKeys:self.observedMaltVariables ofObject:value];
  }

  [[self primitiveMaltAdditions] addObject:value];

  [self didChangeValueForKey:KVO_KEY(maltAdditions)
             withSetMutation:NSKeyValueUnionSetMutation
                usingObjects:changedObjects];

  [self notifyCalculatedValuesInsertingObjects:changedObjects];
}

- (void)removeMaltAdditionsObject:(OBMaltAddition *)value
{
  NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

  if ([[self primitiveMaltAdditions] containsObject:value]) {
    [self stopObservingKeys:self.observedMaltVariables ofObject:value];
  }

  [self willChangeValueForKey:KVO_KEY(maltAdditions)
              withSetMutation:NSKeyValueMinusSetMutation
                 usingObjects:changedObjects];

  [[self primitiveMaltAdditions] removeObject:value];

  [self didChangeValueForKey:KVO_KEY(maltAdditions)
             withSetMutation:NSKeyValueMinusSetMutation
                usingObjects:changedObjects];
  
  [self notifyCalculatedValuesDeletingObjects:changedObjects];
}

@end
