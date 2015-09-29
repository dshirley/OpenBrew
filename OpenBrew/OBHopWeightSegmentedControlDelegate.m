//
//  OBHopWeightSegmentedControlDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBHopWeightSegmentedControlDelegate.h"
#import "OBSettings.h"
#import "OBKvoUtils.h"

@implementation OBHopWeightSegmentedControlDelegate

- (NSArray *)titles
{
  return @[ @"Ounces", @"Grams" ];
}

- (NSArray *)values
{
  return @[ @(OBHopQuantityUnitsImperial), @(OBHopQuantityUnitsMetric) ];
}

- (NSString *)settingsKey
{
  return KVO_KEY(hopQuantityUnits);
}

@end
