//
//  OBMultiPickerTableViewCell.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/1/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

// This view represents the drawer that drops down in the hop and malt addition
// view controllers.  It has to be layed out very manually due to the fact that
// the SegmentedControl is rotated.
@interface OBMultiPickerTableViewCell : UITableViewCell

// TODO: these properties should not be public. For example, setting the segments
// without using "setSegments" would result in improper formatting. These should be
// made private in order to enforce the integrity of the component
@property (nonatomic, strong) IBOutlet UISegmentedControl* selector;
@property (nonatomic, strong) IBOutlet UIPickerView *picker;

- (void)setSegments:(NSArray *)segmentTitles;
@end

@protocol OBMultiPickerDelegate <NSObject>
- (void)segmentSelected:(NSUInteger)segmentIndex;
@end