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
#import "OBSettings.h"

#import "OBMultiPickerTableViewCell.h"
#import "OBHopAdditionTableViewCell.h"

#import "OBAlphaAcidPickerDelegate.h"
#import "OBHopOuncesPickerDelegate.h"
#import "OBHopGramsPickerDelegate.h"
#import "OBHopBoilTimePickerDelegate.h"
#import "OBHopTypePickerDelegate.h"

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

- (void)setHopQuantityUnits:(OBHopQuantityUnits)hopQuantityUnits
{
  _hopQuantityUnits = hopQuantityUnits;

  [self.tableView reloadData];
}

- (void)setIbuFormula:(OBIbuFormula)ibuFormula
{
  _ibuFormula = ibuFormula;

  [self.tableView reloadData];
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  OBHopAddition *hopAddition = (OBHopAddition *)ingredientData;
  OBHopAdditionTableViewCell *hopCell = (OBHopAdditionTableViewCell *)cell;

  hopCell.hopVariety.text = hopAddition.name;

  float alphaAcids = [hopAddition.alphaAcidPercent floatValue];
  hopCell.alphaAcid.text = [NSString stringWithFormat:@"%.1f%%", alphaAcids];

  [hopCell setHopType:[hopAddition.type integerValue]];

  NSInteger boilMinutes = [hopAddition.boilTimeInMinutes integerValue];
  hopCell.boilTime.text = [NSString stringWithFormat:@"%ld", (long)boilMinutes];

  hopCell.boilUnits.text = @"min";

  switch (self.hopAdditionMetricToDisplay) {
    case OBHopAdditionMetricIbu:
      hopCell.primaryMetric.text = [NSString stringWithFormat:@"%d IBUs",
                                    (int)roundf([hopAddition ibuContribution:self.ibuFormula])];
      break;
    case OBHopAdditionMetricWeight:
      if (OBHopQuantityUnitsImperial == self.hopQuantityUnits) {
        hopCell.primaryMetric.text = [NSString stringWithFormat:@"%.1f oz",
                                      [hopAddition.quantityInOunces floatValue]];
      } else if (OBHopQuantityUnitsMetric == self.hopQuantityUnits) {
        hopCell.primaryMetric.text = [NSString stringWithFormat:@"%d g",
                                      (int)roundf([hopAddition.quantityInGrams floatValue])];
      } else {
        NSAssert(NO, @"Unrecognized units: %@", @(self.hopQuantityUnits));
      }
      
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

  id<OBPickerDelegate> alphaAcidPickerDelegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:hopAddition];
  id<OBPickerDelegate> hopBoilTimeDelegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:hopAddition];
  id<OBPickerDelegate> hopTypePickerDelegate = [[OBHopTypePickerDelegate alloc] initWithHopAddition:hopAddition];
  id<OBPickerDelegate> hopQuantityPickerDelegate = nil;

  if (OBHopQuantityUnitsImperial == self.hopQuantityUnits) {
    hopQuantityPickerDelegate = [[OBHopOuncesPickerDelegate alloc] initWithHopAddition:hopAddition];
  } else if (OBHopQuantityUnitsMetric == self.hopQuantityUnits) {
    hopQuantityPickerDelegate = [[OBHopGramsPickerDelegate alloc] initWithHopAddition:hopAddition];
  } else {
    NSAssert(NO, @"Invalid hop quantity units: %@", @(self.hopQuantityUnits));
  }

  [drawerCell.multiPickerView removeAllPickers];
  [drawerCell.multiPickerView addPickerDelegate:hopQuantityPickerDelegate withTitle:@"Quantity"];
  [drawerCell.multiPickerView addPickerDelegate:alphaAcidPickerDelegate withTitle:@"Alpha Acid %"];
  [drawerCell.multiPickerView addPickerDelegate:hopBoilTimeDelegate withTitle:@"Boil Time"];
  [drawerCell.multiPickerView addPickerDelegate:hopTypePickerDelegate withTitle:@"Type"];
  [drawerCell.multiPickerView setSelectedPicker:self.selectedPickerIndex];
  drawerCell.multiPickerView.delegate = self;
}


- (void)selectedPickerDidChange:(NSInteger)pickerIndex
{
  self.selectedPickerIndex = pickerIndex;
}

@end
