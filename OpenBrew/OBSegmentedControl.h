//
//  OBSegmentedControl.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/28/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OBSegmentedControlDelegate <NSObject>

- (NSArray *)segmentTitlesForSegmentedControl:(UISegmentedControl *)segmentedControl;

- (void)segmentedControl:(UISegmentedControl *)segmentedControl segmentSelected:(NSInteger)index;

- (NSInteger)initiallySelectedSegmentForSegmentedControl:(UISegmentedControl *)segmentedControl;

@end

@interface OBSegmentedControl : UISegmentedControl

@property (nonatomic, weak) id<OBSegmentedControlDelegate> delegate;

// This segmented control automatically logs google analytics events. This property
// sets the google analytics category when logging an event
@property (nonatomic) NSString *gaCategory;

@end
