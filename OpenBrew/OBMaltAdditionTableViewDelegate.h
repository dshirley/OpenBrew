//
//  OBMaltAdditionTableViewDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"
#import "OBSettings.h"
#import "OBMultiPickerView.h"

@interface OBMaltAdditionTableViewDelegate : OBDrawerTableViewDelegate <OBMultiPickerViewDelegate>

@property (nonatomic, assign) OBMaltAdditionMetric maltAdditionMetricToDisplay;
@property (nonatomic) OBRecipe *recipe;
@property (nonatomic) UITableView *tableView;
@property (nonatomic, assign) NSInteger selectedPickerIndex;

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView andGACategory:(NSString *)gaCategory;

@end
