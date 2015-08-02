//
//  OBMaltAdditionTableViewDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"
#import "OBBrewery.h"

@interface OBMaltAdditionTableViewDelegate : OBDrawerTableViewDelegate

@property (nonatomic, assign) OBMaltAdditionMetric maltAdditionMetricToDisplay;
@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, strong) UITableView *tableView;

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView andGACategory:(NSString *)gaCategory;

@end
