//
//  OBMaltDisplayMetricSegmentedControlDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMaltDisplayMetricSegmentedControlDelegate.h"
#import "OBSettings.h"
#import "OBKvoUtils.h"

@implementation OBMaltDisplayMetricSegmentedControlDelegate

- (NSArray *)titles
{
  return @[ @"Weight", @"%" ];
}

- (NSArray *)values
{
  return @[ @(OBMaltAdditionMetricWeight), @(OBMaltAdditionMetricPercentOfGravity) ];;
}

- (NSString *)settingsKey
{
  return KVO_KEY(maltAdditionDisplayMetric);
}

@end
