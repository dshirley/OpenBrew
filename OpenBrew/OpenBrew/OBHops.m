//
//  OBHops.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHops.h"
#import "Math.h"

@implementation OBHops

@dynamic name;
@dynamic defaultAlphaAcidPercent;

@end


@implementation OBHopAddition

@dynamic alphaAcidPercent;
@dynamic boilTimeInMinutes;
@dynamic quantityInOunces;

// Used to convert oz/gallon to gram/liter
#define IMPERIAL_TO_METRIC_CONST 74.891

- (float)ibuContributionWithBoilSize:(float)gallons andGravity:(float)gravity {
  // Using John Palmer's formula from How To Brew
  // http://www.howtobrew.com/section1/chapter5-5.html

  float alphaAcidUnits = [self alphaAcidUnits];
  float utilization = [self utilizationForGravity:gravity];

  return (alphaAcidUnits * utilization * IMPERIAL_TO_METRIC_CONST) / gallons;
}

- (float)alphaAcidUnits {
  return [self alphaAcidPercent] * [self quantityInOunces];
}

- (float)utilizationForGravity:(float)gravity {
  // Tinseth formula:
  // (1.65 * 0.000125^(wort gravity - 1)) * (1 - e^(-0.04 * time in mins) )

  float gravityFactor = 1.65 * powf(0.000125, gravity - 1);
  float timeFactor = (1 - powf(M_E, -.04 * [self boilTimeInMinutes])) / 4.15;

  return gravityFactor * timeFactor;
}

@end
