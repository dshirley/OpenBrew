//
//  OBMaltAdditionTableViewDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionTableViewDelegate.h"

#import "OBMaltAddition.h"
#import "OBRecipe.h"
#import "OBMalt.h"
#import "OBMultiPickerTableViewCell.h"
#import "OBMaltAdditionTableViewCell.h"

#import "OBMaltQuantityPickerDelegate.h"
#import "OBMaltColorPickerDelegate.h"

#import "OBMultiPickerView.h"

@interface OBMaltAdditionTableViewDelegate()

@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation OBMaltAdditionTableViewDelegate

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView andGACategory:(NSString *)gaCategory
{
  self = [super initWithGACategory:gaCategory];

  if (self) {
    self.recipe = recipe;
    self.tableView = tableView;
  }

  return self;
}

- (void)setMaltAdditionMetricToDisplay:(OBMaltAdditionMetric)newSelection
{
  _maltAdditionMetricToDisplay = newSelection;

  // TODO: perhaps a reload is more heavy weight than we need? Not sure...
  // there probably aren't majore performance implications since the data we're
  // dealing with is so small
  [self.tableView reloadData];
}

/**
 * Returns the malts in this recipe in an array format that represents the order
 * of elements in the table view.
 */
- (NSArray *)ingredientData
{
  NSSortDescriptor *sortByDisplayOrder;

  sortByDisplayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder"
                                                   ascending:YES];

  NSArray *sortSpecification = @[ sortByDisplayOrder ];

  return @[ [[self.recipe maltAdditions] sortedArrayUsingDescriptors:sortSpecification] ];
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  OBMaltAddition *maltAddition = (OBMaltAddition *)ingredientData;
  OBMaltAdditionTableViewCell *maltCell = (OBMaltAdditionTableViewCell *)cell;

  maltCell.maltVariety.text = maltAddition.malt.name;

  switch (self.maltAdditionMetricToDisplay) {
    case OBMaltAdditionMetricWeight:
      maltCell.primaryMetric.text = [maltAddition quantityText];
      break;
    case OBMaltAdditionMetricPercentOfGravity:
      maltCell.primaryMetric.text = [NSString stringWithFormat:@"%@%%",
                                     @([maltAddition percentOfGravity])];
      break;
  }

  maltCell.color.text = [NSString stringWithFormat:@"%@ Lovibond", maltAddition.lovibond];
}

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData
{
  OBMultiPickerTableViewCell *drawerCell = (OBMultiPickerTableViewCell *)cell;

  OBMaltAddition *maltAddition = [self ingredientForDrawer];

  OBMaltQuantityPickerDelegate *quantityPickerDelegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:maltAddition];
  OBMaltColorPickerDelegate *colorPickerDelegate = [[OBMaltColorPickerDelegate alloc] initWithMaltAddition:maltAddition];

  [drawerCell.multiPickerView removeAllPickers];
  [drawerCell.multiPickerView addPickerDelegate:quantityPickerDelegate withTitle:@"Quantity"];
  [drawerCell.multiPickerView addPickerDelegate:colorPickerDelegate withTitle:@"Color"];
}


@end
