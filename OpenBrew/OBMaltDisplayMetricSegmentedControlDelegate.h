//
//  OBMaltDisplayMetricSegmentedControlDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBSettingsSegmentedControlDelegate.h"

@interface OBMaltDisplayMetricSegmentedControlDelegate : OBSettingsSegmentedControlDelegate

- (NSArray *)titles;

- (NSArray *)values;

- (NSString *)settingsKey;

@end
