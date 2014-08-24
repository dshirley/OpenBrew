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
@end

@interface OBRecipe(PrimitiveAccessors)

- (NSMutableSet *)primitiveHopAdditions;
- (NSMutableSet *)primitiveMaltAdditions;

@end

@implementation OBRecipe

@synthesize observedHopVariables;
@synthesize observedMaltVariables;

@dynamic batchSizeInGallons;
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
    self.batchSizeInGallons = @5;
    [self initializeVariableLists];
  }

  return self;
}

- (void)initializeVariableLists
{
  self.observedHopVariables = [NSSet setWithObjects:
                               KVO_KEY(alphaAcidPercent),
                               KVO_KEY(boilTimeInMinutes),
                               KVO_KEY(quantityInOunces), nil];

  self.observedMaltVariables = [NSSet setWithObjects:
                                KVO_KEY(quantityInPounds),
                                KVO_KEY(lovibond), nil];
}

- (void)awakeFromFetch
{
  [self initializeVariableLists];
  for (OBHopAddition *hopAddition in self.hopAdditions) {
    [self startObservingKeys:self.observedHopVariables ofObject:hopAddition];
  }

  for (OBMaltAddition *maltAddition in self.maltAdditions) {
    [self startObservingKeys:self.observedMaltVariables ofObject:maltAddition];
  }

  [self addObserver:self forKeyPath:KVO_KEY(batchSizeInGallons) options:0 context:nil];
}

- (float)boilSizeInGallons {
  // FIXME: this should be tunable rather than just adding 2 gallons
  return [[self batchSizeInGallons] floatValue] + 2;
}

- (float)postBoilSizeInGallons {
  // FIXME: this should be tunable rather than just adding 1 gallons
  return [[self batchSizeInGallons] floatValue] + 1;
}

- (float)gravityUnits {
  float gravityUnits = 0.0;

  // FIXME: don't hardcode the efficiency
  float efficiency = .75; //[[[OBBrewery instance] mashEfficiency] floatValue];

  for (OBMaltAddition *malt in [self maltAdditions]) {
    gravityUnits += [malt gravityUnitsWithEfficiency:efficiency];
  }

  return gravityUnits;
}

- (float)originalGravity {
  return 1 + ([self gravityUnits] / [self postBoilSizeInGallons] / 1000);
}

- (float)finalGravity {
  float attenuationLevel = [[[self yeast] yeast] estimatedAttenuationAsDecimal];
  float finalGravityUnits = [self gravityUnits] * (1 - attenuationLevel);
  return finalGravityUnits / [self postBoilSizeInGallons];
}

- (float)boilGravity {
  return 1 + ([self gravityUnits] / [self boilSizeInGallons] / 1000);
}

- (float)IBUs {
  float ibus = 0.0;
  float postBoilSizeInGallons = [self postBoilSizeInGallons];
  float boilGravity = [self boilGravity];

  for (OBHopAddition *hops in [self hopAdditions]) {
    ibus += [hops ibuContributionWithBoilSize:postBoilSizeInGallons
                                   andGravity:boilGravity];
  }

  return ibus;
}

// Using the Morey equation: http://brewwiki.com/index.php/Estimating_Color
// SRM_Color = 1.4922 * [MCU ^ 0.6859] -- Good for beer colors < 50 SRM
- (float)colorInSRM {
  float maltColorUnits = 0.0;

  for (OBMaltAddition *malt in [self maltAdditions]) {
    maltColorUnits += [malt maltColorUnitsForBoilSize:[self postBoilSizeInGallons]];
  }

  return 1.4922 * powf(maltColorUnits, 0.6859);
}

- (float)alcoholByVolume {
  // FIXME
  return 0;
}

- (void)save {
  // FIXME
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([self.observedMaltVariables containsObject:keyPath] ||
      [self.observedHopVariables containsObject:keyPath] ||
      [KVO_KEY(batchSizeInGallons) isEqualToString:keyPath])
  {
    [self willChangeValueForKey:KVO_KEY(IBUs)];
    [self didChangeValueForKey:KVO_KEY(IBUs)];
    [self willChangeValueForKey:KVO_KEY(originalGravity)];
    [self didChangeValueForKey:KVO_KEY(originalGravity)];
    [self willChangeValueForKey:KVO_KEY(boilGravity)];
    [self didChangeValueForKey:KVO_KEY(boilGravity)];
    [self willChangeValueForKey:KVO_KEY(colorInSRM)];
    [self didChangeValueForKey:KVO_KEY(colorInSRM)];
  } else {
    [NSException raise:@"Unrecognized Key" format:@"Key: %@", keyPath];
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
}

@end
