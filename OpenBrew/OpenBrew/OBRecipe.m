//
//  OBRecipe.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipe.h"
#import "OBYeast.h"
#import "OBBrewHouseSettings.h"

@interface OBRecipe()

@property (retain, readwrite, nonatomic) NSMutableArray *malts;
@property (retain, readwrite, nonatomic) NSMutableArray *hops;

@end

@implementation OBRecipe

- (NSArray *)malts {
  return [NSArray arrayWithArray:_malts];
}

- (NSArray *)hops {
  return [NSArray arrayWithArray:_hops];
}

- (void)addMalt:(OBMalt *)malt {
  [_malts addObject:malt];
}

- (void)addHops:(OBHops *)hops {
  [_hops addObject:hops];
}

- (float)boilSizeInGallons {
  // FIXME: this should be tunable rather than just adding 2 gallons
  return _batchSizeInGallons + 2;
}

- (float)postBoilSizeInGallons {
    // FIXME: this should be tunable rather than just adding 1 gallons
  return _batchSizeInGallons + 1;
}

- (float)gravityUnits {
  float gravityUnits = 0.0;
  float efficiency = [[OBBrewHouseSettings instance] mashExtractionEfficiency];

  for (OBMalt *malt in _malts) {
    gravityUnits += [malt contributedGravityUnitsWithEfficiency:efficiency];
  }

  return gravityUnits;
}

- (float)originalGravity {
  return [self gravityUnits] / _batchSizeInGallons;
}

- (float)finalGravity {
  float finalGravityUnits = [self gravityUnits] * (1 - [_yeast estimatedAttenuationAsDecimal]);
  return finalGravityUnits / [self postBoilSizeInGallons];
}

- (float)boilGravity {
  return [self gravityUnits] / [self boilSizeInGallons];
}

- (float)IBUs {
  float ibus = 0.0;
  float boilSizeInGallons = [self boilSizeInGallons];
  float boilGravity = [self boilGravity];

  for (OBHops *hops in _hops) {
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
