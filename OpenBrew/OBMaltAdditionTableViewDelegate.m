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

#import "OBKvoUtils.h"

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

  [self.tableView reloadData];
}

/**
 * Returns the malts in this recipe in an array format that represents the order
 * of elements in the table view.
 */
- (NSArray *)ingredientData
{
  NSArray *maltAdditionsSorted = [self.recipe maltAdditionsSorted];

  if (!maltAdditionsSorted) {
    // This only occurs during unit testing, when the managedObjectContext is being set to nil
    maltAdditionsSorted = @[];
  }

  return @[ maltAdditionsSorted ];
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  OBMaltAddition *maltAddition = (OBMaltAddition *)ingredientData;
  OBMaltAdditionTableViewCell *maltCell = (OBMaltAdditionTableViewCell *)cell;

  maltCell.maltVariety.text = maltAddition.name;

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
  OBMaltAddition *maltAddition = (OBMaltAddition *)ingredientData;

  OBMaltQuantityPickerDelegate *quantityPickerDelegate = [OBMaltQuantityPickerDelegate maltQuantityPickerDelegateWith:maltAddition];
  
  OBMaltColorPickerDelegate *colorPickerDelegate = [[OBMaltColorPickerDelegate alloc] initWithMaltAddition:maltAddition];

  [drawerCell.multiPickerView removeAllPickers];
  [drawerCell.multiPickerView addPickerDelegate:quantityPickerDelegate withTitle:@"Quantity"];
  [drawerCell.multiPickerView addPickerDelegate:colorPickerDelegate withTitle:@"Color"];
  [drawerCell.multiPickerView setSelectedPicker:self.selectedPickerIndex];
  drawerCell.multiPickerView.delegate = self;
}

- (void)selectedPickerDidChange:(NSInteger)pickerIndex
{
  self.selectedPickerIndex = pickerIndex;
}


@end
