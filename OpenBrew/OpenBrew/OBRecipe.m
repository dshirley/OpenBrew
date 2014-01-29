//
//  OBRecipe.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipe.h"
#import "OBYeast.h"
#import "OBBrewery.h"

@implementation OBRecipe

@dynamic name;
@dynamic batchSizeInGallons;
@dynamic hops;
@dynamic malts;
@dynamic yeast;

- (float)boilSizeInGallons {
  // FIXME: this should be tunable rather than just adding 2 gallons
  return [self batchSizeInGallons] + 2;
}

- (float)postBoilSizeInGallons {
    // FIXME: this should be tunable rather than just adding 1 gallons
  return [self batchSizeInGallons] + 1;
}

- (float)gravityUnits {
  float gravityUnits = 0.0;
  float efficiency = [[[OBBrewery instance] mashEfficiency] floatValue];

  for (OBMaltAddition *malt in [self malts]) {
    gravityUnits += [malt gravityUnitsWithEfficiency:efficiency];
  }

  return gravityUnits;
}

- (float)originalGravity {
  return [self gravityUnits] / [self batchSizeInGallons];
}

- (float)finalGravity {
  float attenuationLevel = [[[self yeast] yeast] estimatedAttenuationAsDecimal];
  float finalGravityUnits = [self gravityUnits] * (1 - attenuationLevel);
  return finalGravityUnits / [self postBoilSizeInGallons];
}

- (float)boilGravity {
  return [self gravityUnits] / [self boilSizeInGallons];
}

- (float)IBUs {
  float ibus = 0.0;
  float boilSizeInGallons = [self boilSizeInGallons];
  float boilGravity = [self boilGravity];

  for (OBHopAddition *hops in [self hops]) {
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
