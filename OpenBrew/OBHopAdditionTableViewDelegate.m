//
//  OBHopAdditionTableViewDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopAdditionTableViewDelegate.h"

#import "OBHopAddition.h"
#import "OBRecipe.h"
#import "OBHops.h"
#import "OBBrewery.h"

#import "OBMultiPickerTableViewCell.h"
#import "OBHopAdditionTableViewCell.h"

#import "OBAlphaAcidPickerDelegate.h"
#import "OBHopQuantityPickerDelegate.h"
#import "OBHopBoilTimePickerDelegate.h"

@implementation OBHopAdditionTableViewDelegate

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView andGACategory:(NSString *)gaCategory
{
  self = [super initWithGACategory:gaCategory];

  if (self) {
    self.recipe = recipe;
    self.tableView = tableView;
  }

  return self;
}

/**
 * Returns the hops in this recipe in an array format that represents the order
 * of elements in the table view.
 */
- (NSArray *)ingredientData
{
  NSArray *hopAdditionsSorted = [self.recipe hopAdditionsSorted];

  if (!hopAdditionsSorted) {
    // This only occurs during unit tests when the managedObjectContext is being set to nil
    hopAdditionsSorted = @[];
  }

  return @[ hopAdditionsSorted ];
}

- (void)setHopAdditionMetricToDisplay:(OBHopAdditionMetric)newSelection
{
  _hopAdditionMetricToDisplay = newSelection;

  [self.tableView reloadData];
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  OBHopAddition *hopAddition = (OBHopAddition *)ingredientData;
  OBHopAdditionTableViewCell *hopCell = (OBHopAdditionTableViewCell *)cell;

  hopCell.hopVariety.text = hopAddition.hops.name;

  float alphaAcids = [hopAddition.alphaAcidPercent floatValue];
  hopCell.alphaAcid.text = [NSString stringWithFormat:@"%.1f%%", alphaAcids];

  NSInteger boilMinutes = [hopAddition.boilTimeInMinutes integerValue];
  hopCell.boilTime.text = [NSString stringWithFormat:@"%ld", (long)boilMinutes];

  hopCell.boilUnits.text = @"min";

  switch (self.hopAdditionMetricToDisplay) {
    case OBHopAdditionMetricIbu:
      hopCell.primaryMetric.text = [NSString stringWithFormat:@"%d IBUs",
                                    (int)roundf([hopAddition ibuContribution])];
      break;
    case OBHopAdditionMetricWeight:
      hopCell.primaryMetric.text = [NSString stringWithFormat:@"%.1f oz",
                                    [hopAddition.quantityInOunces floatValue]];
      break;
    default:
      [NSException raise:@"Invalid hop addition metric"
                  format:@"%d", (int) self.hopAdditionMetricToDisplay];
  }
}

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData
{
  OBMultiPickerTableViewCell *drawerCell = (OBMultiPickerTableViewCell *)cell;
  OBHopAddition *hopAddition = (OBHopAddition *)ingredientData;

  OBAlphaAcidPickerDelegate *alphaAcidPickerDelegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:hopAddition];
  OBHopQuantityPickerDelegate *hopQuantityPickerDelegate = [[OBHopQuantityPickerDelegate alloc] initWithHopAddition:hopAddition];
  OBHopBoilTimePickerDelegate *hopBoilTimeDelegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:hopAddition];

  [drawerCell.multiPickerView removeAllPickers];
  [drawerCell.multiPickerView addPickerDelegate:hopQuantityPickerDelegate withTitle:@"Quantity"];
  [drawerCell.multiPickerView addPickerDelegate:alphaAcidPickerDelegate withTitle:@"Alpha Acid %"];
  [drawerCell.multiPickerView addPickerDelegate:hopBoilTimeDelegate withTitle:@"Boil Time"];
  [drawerCell.multiPickerView setSelectedPicker:self.selectedPickerIndex];
  drawerCell.multiPickerView.delegate = self;
}


- (void)selectedPickerDidChange:(NSInteger)pickerIndex
{
  self.selectedPickerIndex = pickerIndex;
}

@end
