//
//  OBMultiPickerTableViewCell.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/1/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBMultiPickerView;

// This view represents the drawer that drops down in the hop and malt addition
// view controllers.  It has to be layed out very manually due to the fact that
// the SegmentedControl is rotated.
@interface OBMultiPickerTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet OBMultiPickerView *multiPickerView;

@end
