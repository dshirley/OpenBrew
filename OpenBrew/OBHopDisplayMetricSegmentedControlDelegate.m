//
//  OBHopDisplayMetricSegmentedControlDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBHopDisplayMetricSegmentedControlDelegate.h"
#import "OBSettings.h"
#import "OBKvoUtils.h"

@implementation OBHopDisplayMetricSegmentedControlDelegate

- (NSArray *)titles
{
  return @[ @"Ounces", @"Grams", @"IBUs" ];
}

- (NSArray *)values
{
  return @[ @(OBHopAdditionMetricOunces), @(OBHopAdditionMetricGrams), @(OBHopAdditionMetricIbu) ];
}

- (NSString *)settingsKey
{
  return KVO_KEY(hopAdditionDisplayMetric);
}

@end
