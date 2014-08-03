//
//  OBMultiPickerTableViewCell.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/1/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBMultiPickerTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UISegmentedControl* selector;
@property (nonatomic, weak) IBOutlet UIPickerView *picker;
@end

@protocol OBMultiPickerDelegate <NSObject>
- (void)segmentSelected:(NSUInteger)segmentIndex;
@end