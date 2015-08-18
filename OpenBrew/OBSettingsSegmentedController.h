//
//  OBSettingsSegmentedController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/31/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBBrewery;

typedef void(^OBSegmentSelectedAction)(void);

@interface OBSettingsSegmentedController : NSObject

@property (nonatomic, readonly, weak) UISegmentedControl *segmentedControl;

- (id)initWithSegmentedControl:(UISegmentedControl *)segmentedControl
         googleAnalyticsAction:(NSString *)action;

- (void)addSegment:(NSString *)text actionWhenSelected:(OBSegmentSelectedAction)action;

@end
