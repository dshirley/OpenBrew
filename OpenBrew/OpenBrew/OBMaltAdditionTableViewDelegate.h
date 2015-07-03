//
//  OBMaltAdditionTableViewDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"
#import "OBPickerObserver.h"

// A list of metrics that can be selected for display for malt addition
// line items.  Currently just weight and % of gravity. There could easily be
// more, but since it is easier to add than subtract features, we'll see if
// people request something specific. Color % might be interesting... not sure.
//
// NOTE: The values of this enum must correspond to the values in the
// MaltAdditionDisplaySettings.xib
typedef NS_ENUM(NSInteger, OBMaltAdditionMetric) {
  OBMaltAdditionMetricWeight,
  OBMaltAdditionMetricPercentOfGravity
};

@interface OBMaltAdditionTableViewDelegate : OBDrawerTableViewDelegate

@property (nonatomic, assign) OBMaltAdditionMetric maltAdditionMetricToDisplay;

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView andGACategory:(NSString *)gaCategory;

@end
