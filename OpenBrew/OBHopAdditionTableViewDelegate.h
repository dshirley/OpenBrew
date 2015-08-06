//
//  OBHopAdditionTableViewDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"
#import "OBBrewery.h"
#import "OBMultiPickerView.h"

@interface OBHopAdditionTableViewDelegate : OBDrawerTableViewDelegate <OBMultiPickerViewDelegate>

@property (nonatomic, assign) OBHopAdditionMetric hopAdditionMetricToDisplay;
@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger selectedPickerIndex;

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView andGACategory:(NSString *)gaCategory;

#pragma mark OBDrawerTableViewDelegate Methods

- (NSArray *)ingredientData;

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData;

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData;

@end
