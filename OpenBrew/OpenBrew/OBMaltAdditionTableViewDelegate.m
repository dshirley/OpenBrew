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

#define QUANTITY_SEGMENT_ID 0
#define COLOR_SEGMENT_ID 1

@interface OBMaltAdditionTableViewDelegate()

@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) OBMaltQuantityPickerDelegate *maltQuantityPickerDelegate;
@property (nonatomic, strong) OBMaltColorPickerDelegate *maltColorPickerDelegate;
@end

@implementation OBMaltAdditionTableViewDelegate

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView
{
  self = [super init];

  if (self) {
    self.recipe = recipe;
    self.tableView = tableView;

    self.maltQuantityPickerDelegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:nil andObserver:self];
    self.maltColorPickerDelegate = [[OBMaltColorPickerDelegate alloc] initWithMaltAddition:nil andObserver:self];
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

  return [[self.recipe maltAdditions] sortedArrayUsingDescriptors:sortSpecification];
}

- (void)finishDisplayingDrawerCell:(UITableViewCell *)cell
{
  if (!cell) {
    return;
  }

  OBMultiPickerTableViewCell *drawerCell = (OBMultiPickerTableViewCell *)cell;
  id<OBPickerDelegate> pickerDelegate = (id<OBPickerDelegate>) drawerCell.picker.delegate;

  [pickerDelegate updateSelectionForPicker:drawerCell.picker];
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

  [drawerCell.selector addTarget:self
                         action:@selector(segmentSelected:)
               forControlEvents:UIControlEventValueChanged];

  id pickerDelegate = [self pickerDelegateForSegmentControl:drawerCell.selector];

  [pickerDelegate setMaltAddition:ingredientData];

  drawerCell.picker.delegate = pickerDelegate;
  drawerCell.picker.dataSource = pickerDelegate;
}

#pragma mark - Drawer Management Methods

- (void)segmentSelected:(id)sender
{
  id pickerDelegate = [self pickerDelegateForSegmentControl:sender];
  OBMaltAddition *maltAddition = [self ingredientForDrawer];

  [pickerDelegate setMaltAddition:maltAddition];

  OBMultiPickerTableViewCell *multiCell = (OBMultiPickerTableViewCell *)[self drawerCellForTableView:self.tableView];
  multiCell.picker.delegate = pickerDelegate;
  multiCell.picker.dataSource = pickerDelegate;

  // TODO: perhaps combine these methods
  [self finishDisplayingDrawerCell:multiCell];
}

- (id)pickerDelegateForSegmentControl:(UISegmentedControl *)segmentControl
{
  NSInteger segmentId = segmentControl.selectedSegmentIndex;
  id pickerDelegate = nil;

  switch (segmentId) {
    case QUANTITY_SEGMENT_ID:
      pickerDelegate = self.maltQuantityPickerDelegate;
      break;
    case COLOR_SEGMENT_ID:
      pickerDelegate = self.maltColorPickerDelegate;
      break;
    default:
      NSLog(@"ERROR: Bad segment ID: %ld", (long)segmentId);
      assert(NO);
  }

  return pickerDelegate;
}

- (void)pickerChanged
{
//  OBMultiPickerTableViewCell *cell = (OBMultiPickerTableViewCell *)[self cellBeforeDrawerForTableView:self.tableView];
//  OBMaltAddition *maltAddition = [self ingredientForDrawer];
//  [self populateIngredientCell:cell withIngredientData:maltAddition];

  [self.tableView reloadData];
}

@end
