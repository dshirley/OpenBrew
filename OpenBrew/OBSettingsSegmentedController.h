//
//  OBSettingsSegmentedController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/31/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBBrewery;

@interface OBSettingsSegmentedController : NSObject

@property (nonatomic, readonly, weak) UISegmentedControl *segmentedControl;

- (id)initWithSegmentedControl:(UISegmentedControl *)segmentedControl
                       brewery:(OBBrewery *)brewery
                    settingKey:(NSString *)brewerySettingKey;

- (void)addSegment:(NSString *)text setsValue:(id)value;

// Selects the segment that has a matching value to the current settings of
// brewerySettingKey
- (void)updateSelectedSegment;

@end
