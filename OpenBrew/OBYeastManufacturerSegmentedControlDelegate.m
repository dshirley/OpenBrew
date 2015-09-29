//
//  OBYeastManufacturerSegmentedControlDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBYeastManufacturerSegmentedControlDelegate.h"
#import "OBSettings.h"
#import "OBKvoUtils.h"

@implementation OBYeastManufacturerSegmentedControlDelegate

- (NSArray *)titles
{
  return @[ @"White Labs", @"Wyeast" ];
}

- (NSArray *)values
{
  return @[ @(OBYeastManufacturerWhiteLabs), @(OBYeastManufacturerWyeast) ];;
}

- (NSString *)settingsKey
{
  return KVO_KEY(selectedYeastManufacturer);
}

@end
