//
//  OBHopAdditionTableViewDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"

typedef NS_ENUM(NSInteger, OBHopAdditionMetric) {
  OBHopAdditionDisplayWeight,
  OBHopAdditionDisplayIBU,
  OBHopAdditionDisplayIBUPercent
};

@interface OBHopAdditionTableViewDelegate : OBDrawerTableViewDelegate

@property (nonatomic, assign) OBHopAdditionMetric hopAdditionMetricToDisplay;

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView andGACategory:(NSString *)gaCategory;

@end
