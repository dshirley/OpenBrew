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

@interface OBMaltAdditionTableViewDelegate()
@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) OBMaltQuantityPickerDelegate *maltQuantityPickerDelegate;
@end

@implementation OBMaltAdditionTableViewDelegate

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView
{
  self = [super init];

  if (self) {
    self.recipe = recipe;
    self.tableView = tableView;

    self.maltQuantityPickerDelegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:nil andObserver:self];
  }

  return self;
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

  [self.maltQuantityPickerDelegate updateSelectionForPicker:drawerCell.picker];
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  OBMaltAddition *maltAddition = (OBMaltAddition *)ingredientData;
  OBMaltAdditionTableViewCell *maltCell = (OBMaltAdditionTableViewCell *)cell;

  maltCell.maltVariety.text = maltAddition.malt.name;
  maltCell.quantity.text = [maltAddition quantityText];
  maltCell.color.text = [NSString stringWithFormat:@"%@ Lovibond", maltAddition.lovibond];
}

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData
{
  OBMultiPickerTableViewCell *drawerCell = (OBMultiPickerTableViewCell *)cell;

  // FIXME: hackish casts
  drawerCell.picker.delegate = (id)self.maltQuantityPickerDelegate;
  drawerCell.picker.dataSource = (id)self.maltQuantityPickerDelegate;
  self.maltQuantityPickerDelegate.maltAddition = [self ingredientForDrawer];
}



- (void)pickerChanged
{
  OBMultiPickerTableViewCell *cell = (OBMultiPickerTableViewCell *)[self cellBeforeDrawerForTableView:self.tableView];
  OBMaltAddition *maltAddition = [self ingredientForDrawer];
  [self populateIngredientCell:cell withIngredientData:maltAddition];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    OBMaltAddition *maltToRemove = [self ingredientAtIndexPath:indexPath];
    [self.recipe removeMaltAdditionsObject:maltToRemove];

    int i = 0;
    for (OBMaltAddition *malt in [self ingredientData]) {
      [malt setDisplayOrder:[NSNumber numberWithInt:i]];
      i++;
    }

    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
  }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  NSMutableArray *maltData = [NSMutableArray arrayWithArray:[self ingredientData]];
  OBMaltAddition *maltToMove = maltData[sourceIndexPath.row];
  [maltData removeObjectAtIndex:sourceIndexPath.row];
  [maltData insertObject:maltToMove atIndex:destinationIndexPath.row];

  int i = 0;
  for (OBMaltAddition *malt in maltData) {
    [malt setDisplayOrder:[NSNumber numberWithInt:i]];
    i++;
  }
}

@end
