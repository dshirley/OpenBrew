//
//  OBSettingsSegmentedControlDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//
//  This is an abstract class that makes creating OBSegmentedControlDelegates
//  take about 2 lines of code.  It's inherited by most of the OBSegmentedControlDelegates.
//  To use it, simply provide a list of titles, values, and which key to set
//  in OBSettings when a segment is selected.

#import <Foundation/Foundation.h>
#import "OBSegmentedControl.h"
#import "OBSettings.h"

@interface OBSettingsSegmentedControlDelegate : NSObject <OBSegmentedControlDelegate>

@property (nonatomic, readonly) OBSettings *settings;

- (instancetype)initWithSettings:(OBSettings *)settings;

#pragma mark OBSegmentedControlDelegate methods

- (NSArray *)segmentTitlesForSegmentedControl:(UISegmentedControl *)segmentedControl;

- (void)segmentedControl:(UISegmentedControl *)segmentedControl segmentSelected:(NSInteger)index;

- (NSInteger)initiallySelectedSegmentForSegmentedControl:(UISegmentedControl *)segmentedControl;

#pragma mark Template methods - THESE MUST BE OVERRIDDEN

// The list of titles for the segmented control
- (NSArray *)titles;

// The list of values that correspond to the titles
- (NSArray *)values;

// When a segment is chosen, this is the key that should be set in OBSettings
- (NSString *)settingsKey;

@end
