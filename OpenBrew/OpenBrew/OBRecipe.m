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

@implementation OBRecipe

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
    self.batchSizeInGallons = @5;
  }

  return self;
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
  return 1 + ([self gravityUnits] / [[self batchSizeInGallons] floatValue] / 1000);
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
  float boilSizeInGallons = [self boilSizeInGallons];
  float boilGravity = [self boilGravity];

  for (OBHopAddition *hops in [self hopAdditions]) {
    ibus += [hops ibuContributionWithBoilSize:boilSizeInGallons andGravity:boilGravity];
  }

  return ibus;
}

- (float)alcoholByVolume {
  // FIXME
  return 0;
}

- (void)save {
  // FIXME
}

@end
