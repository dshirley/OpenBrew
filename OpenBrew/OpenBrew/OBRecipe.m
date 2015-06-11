//
//  OBRecipe.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipe.h"
#import "OBBrewery.h"
#import "OBHopAddition.h"
#import "OBMaltAddition.h"
#import "OBYeastAddition.h"
#import "OBYeast.h"
#import "OBKvoUtils.h"

@interface OBRecipe()
@property (nonatomic, strong) NSSet *observedHopVariables;
@property (nonatomic, strong) NSSet *observedMaltVariables;
@property (nonatomic, strong) NSSet *observedRecipeVariables;
@end

@interface OBRecipe(PrimitiveAccessors)

- (NSMutableSet *)primitiveHopAdditions;
- (NSMutableSet *)primitiveMaltAdditions;

@end

@implementation OBRecipe

@synthesize observedHopVariables;
@synthesize observedMaltVariables;
@synthesize observedRecipeVariables;

@dynamic desiredBeerVolumeInGallons;
@dynamic kettleLossageInGallons;
@dynamic fermentorLossageInGallons;
@dynamic boilOffInGallons;
@dynamic name;
@dynamic brewery;
@dynamic hopAdditions;
@dynamic maltAdditions;
@dynamic yeast;

- (id)initWithContext:(NSManagedObjectContext *)context
{
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Recipe"
                                          inManagedObjectContext:context];

  self = [self initWithEntity:desc insertIntoManagedObjectContext:context];

  if (self) {
    // TODO: should this be in awake from insert instead?
    self.desiredBeerVolumeInGallons = @5;
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

- (void)prepareForDeletion
{
  [self stopObserving];
}

- (float)boilSizeInGallons {
  return [self.desiredBeerVolumeInGallons floatValue] + [self.boilOffInGallons floatValue];
}

- (float)wortVolumeAfterBoilInGallons {
  return [self.desiredBeerVolumeInGallons floatValue] +
    [self.kettleLossageInGallons floatValue] +
    [self.fermentorLossageInGallons floatValue];
}

- (float)efficiency
{
  // FIXME: don't hardcode the efficiency
  return .75; //[[[OBBrewery instance] mashEfficiency] floatValue];
}

- (float)gravityUnits {
  float gravityUnits = 0.0;
  float efficiency = [self efficiency];

  for (OBMaltAddition *malt in [self maltAdditions]) {
    gravityUnits += [malt gravityUnitsWithEfficiency:efficiency];
  }

  return gravityUnits;
}

- (NSInteger)percentTotalGravityOfMaltAddition:(OBMaltAddition *)maltAddition
{
  assert([self.maltAdditions containsObject:maltAddition]);

  float gravityUnits = [self gravityUnits];
  float maltGravityUnits = [maltAddition gravityUnitsWithEfficiency:[self efficiency]];

  NSInteger percentOfTotal = 0;
  if (gravityUnits > 0) {
    percentOfTotal = roundf(100.0 * maltGravityUnits / gravityUnits);
  }

  return percentOfTotal;
}

- (float)ibusForHopAddition:(OBHopAddition *)hopAddition
{
  assert([self.hopAdditions containsObject:hopAddition]);

  return [hopAddition ibuContributionWithBoilSize:[self wortVolumeAfterBoilInGallons]
                                       andGravity:[self boilGravity]];
}

- (NSInteger)percentIBUOfHopAddition:(OBHopAddition *)hopAddition
{
  assert([self.hopAdditions containsObject:hopAddition]);

  float ibusTotal = [self IBUs];

  // TODO: this ibu contribution method is really confusing
  float ibusOfHopAddition = [hopAddition ibuContributionWithBoilSize:[self wortVolumeAfterBoilInGallons] andGravity:[self boilGravity]];

  NSInteger percentOfTotal = 0;
  if (ibusTotal > 0) {
    percentOfTotal = roundf(100.0 * ibusOfHopAddition / ibusTotal);
  }

  return percentOfTotal;
}

- (float)originalGravity {
  return 1 + ([self gravityUnits] / [self wortVolumeAfterBoilInGallons] / 1000);
}

- (float)finalGravity {
  float attenuationLevel = [[[self yeast] yeast] estimatedAttenuationAsDecimal];
  float finalGravityUnits = [self gravityUnits] * (1 - attenuationLevel);
  return finalGravityUnits / [self wortVolumeAfterBoilInGallons];
}

- (float)boilGravity {
  return 1 + ([self gravityUnits] / [self boilSizeInGallons] / 1000);
}

- (float)IBUs {
  float ibus = 0.0;
  float wortVolumeAfterBoilInGallons = [self wortVolumeAfterBoilInGallons];
  float boilGravity = [self boilGravity];

  for (OBHopAddition *hops in [self hopAdditions]) {
    ibus += [hops ibuContributionWithBoilSize:wortVolumeAfterBoilInGallons
                                   andGravity:boilGravity];
  }

  return ibus;
}

// Using the Morey equation: http://brewwiki.com/index.php/Estimating_Color
// SRM_Color = 1.4922 * [MCU ^ 0.6859] -- Good for beer colors < 50 SRM
- (float)colorInSRM
{
  float maltColorUnits = 0.0;

  for (OBMaltAddition *malt in [self maltAdditions]) {
    maltColorUnits += [malt maltColorUnitsForBoilSize:[self wortVolumeAfterBoilInGallons]];
  }

  return 1.4922 * powf(maltColorUnits, 0.6859);
}

- (float)alcoholByVolume
{
  // FIXME
  return 0;
}

- (float)bitternessToGravityRatio
{
  float nonDecimalGravity = 1000.0 * ([self originalGravity] - 1);
  float ibu = [self IBUs];

  if (nonDecimalGravity == 0) {
    return INFINITY;
  }

  return ibu / nonDecimalGravity;
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
                                  KVO_KEY(desiredBeerVolumeInGallons),
                                  KVO_KEY(boilOffInGallons),
                                  KVO_KEY(kettleLossageInGallons),
                                  KVO_KEY(fermentorLossageInGallons), nil];
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
  [self willChangeValueForKey:KVO_KEY(IBUs)];
  [self didChangeValueForKey:KVO_KEY(IBUs)];
  [self willChangeValueForKey:KVO_KEY(originalGravity)];
  [self didChangeValueForKey:KVO_KEY(originalGravity)];
  [self willChangeValueForKey:KVO_KEY(boilGravity)];
  [self didChangeValueForKey:KVO_KEY(boilGravity)];
  [self willChangeValueForKey:KVO_KEY(colorInSRM)];
  [self didChangeValueForKey:KVO_KEY(colorInSRM)];
  [self willChangeValueForKey:KVO_KEY(boilSizeInGallons)];
  [self willChangeValueForKey:KVO_KEY(wortVolumeAfterBoilInGallons)];
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
    [self startObservingKeys:self.observedHopVariables ofObject:value];
  }

  [[self primitiveHopAdditions] addObject:value];

  [self didChangeValueForKey:KVO_KEY(hopAdditions)
             withSetMutation:NSKeyValueUnionSetMutation
                usingObjects:changedObjects];

  [self notifyCalculatedValuesChanged];
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

  [self notifyCalculatedValuesChanged];
}

#pragma mark - Malt Addition Properties

- (void)addMaltAdditionsObject:(OBMaltAddition *)value
{
  NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];


  [self willChangeValueForKey:KVO_KEY(maltAdditions)
              withSetMutation:NSKeyValueUnionSetMutation
                 usingObjects:changedObjects];

  if (![[self primitiveMaltAdditions] containsObject:value]) {
    [self startObservingKeys:self.observedMaltVariables ofObject:value];
  }

  [[self primitiveMaltAdditions] addObject:value];

  [self didChangeValueForKey:KVO_KEY(maltAdditions)
             withSetMutation:NSKeyValueUnionSetMutation
                usingObjects:changedObjects];

  [self notifyCalculatedValuesChanged];
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
  
  [self notifyCalculatedValuesChanged];
}

@end
