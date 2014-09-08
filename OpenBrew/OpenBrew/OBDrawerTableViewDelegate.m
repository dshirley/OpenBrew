//
//  OBDrawerTableViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/6/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"
#import "OBIngredientAddition.h"

static NSString *const INGREDIENT_ADDITION_CELL = @"IngredientAddition";
static NSString *const DRAWER_CELL = @"DrawerCell";

@interface OBDrawerTableViewDelegate ()
@property (assign) NSInteger drawerCellRowHeight;
@end

@implementation OBDrawerTableViewDelegate

- (id)init
{
  self = [super init];

  if (self) {
    // Really dumb way to get the default height of a UIPickerView
    // Apple doesn't provide a constant, though, and the default shown in
    // Interface Builder is wrong (it says 162.  For iOS 7 it is 216)
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 77, 320, 0)];
    self.drawerCellRowHeight = picker.frame.size.height;
  }

  return self;
}

/**
 * Returns the hops in this recipe in an array format that represents the order
 * of elements in the table view.
 */
- (NSArray *)ingredientData {
  assert(YES);
  return nil;
}

/**
 * Lookup the hop addition at the given index in the UITableView
 */
- (id<OBIngredientAddition>)ingredientAtIndexPath:(NSIndexPath *)indexPath
{
  // There can't be a hop addition in the same index as the drawer
  assert(!self.drawerIndexPath || self.drawerIndexPath.row != indexPath.row);

  NSArray *data = [self ingredientData];

  NSUInteger index = indexPath.row;
  if ([self drawerIsOpen] && self.drawerIndexPath.row < indexPath.row) {
    index -= 1;
  }

  return data[index];
}

- (NSIndexPath *)indexPathOfCellBeforeDrawer
{
  NSInteger cellRow = self.drawerIndexPath.row - 1;
  NSIndexPath *cellBeforeDrawerIndex = [NSIndexPath indexPathForRow:cellRow inSection:0];
  return cellBeforeDrawerIndex;
}

- (id)ingredientForDrawer
{
  NSIndexPath *cellBeforeDrawer = [self indexPathOfCellBeforeDrawer];
  return [self ingredientAtIndexPath:cellBeforeDrawer];
}

- (BOOL)drawerIsOpen
{
  return (self.drawerIndexPath != nil);
}

- (BOOL)drawerIsAtIndex:(NSIndexPath *)indexPath
{
  return ([self drawerIsOpen] && self.drawerIndexPath.row == indexPath.row);
}

- (UITableViewCell *)cellBeforeDrawerForTableView:(UITableView *)tableView;
{
  UITableViewCell *cell = nil;

  if ([self drawerIsOpen]) {
    NSIndexPath *index = [self indexPathOfCellBeforeDrawer];
    cell = [tableView cellForRowAtIndexPath:index];
  }

  return cell;
}

- (UITableViewCell *)drawerCellForTableView:(UITableView *)tableView
{
  UITableViewCell *cell = nil;

  if ([self drawerIsOpen]) {
    cell = [tableView cellForRowAtIndexPath:[self drawerIndexPath]];
  }

  return cell;
}

- (void)closeDrawerForTableView:(UITableView *)tableView
{
  if ([self drawerIsOpen]) {
    [tableView deleteRowsAtIndexPaths:@[self.drawerIndexPath]
                     withRowAnimation:UITableViewRowAnimationFade];

    self.drawerIndexPath = nil;
  }
}

- (void)tableView:(UITableView *)tableView
  openDrawerAtRow:(NSUInteger)row
        inSection:(NSUInteger)section
{
  self.drawerIndexPath = [NSIndexPath indexPathForRow:row
                                            inSection:section];

  [tableView insertRowsAtIndexPaths:@[self.drawerIndexPath]
                   withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return ([self drawerIsAtIndex:indexPath] ? self.drawerCellRowHeight : self.drawerCellRowHeight / 4);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if ([self drawerIsAtIndex:indexPath]) {
    return;
  }

  [tableView beginUpdates];

  // indicates if the drawer is below "indexPath", help us determine which row to reveal
  BOOL before = NO;
  BOOL sameCellClicked = (self.drawerIndexPath.row - 1 == indexPath.row);

  if ([self drawerIsOpen]) {
    // Close the old drawer if one is open
    before = self.drawerIndexPath.row < indexPath.row;
    [self closeDrawerForTableView:tableView];
  }

  if (!sameCellClicked) {
    // Open the new drawer
    NSInteger row = (before ? indexPath.row : indexPath.row + 1);
    [self tableView:tableView openDrawerAtRow:row inSection:0];
  }

  [tableView endUpdates];

  // Annoyingly, it seems that a cell cannot be selected until it is visible on
  // the screen.  However, we have to set the delegate at cell creation time so
  // that iOS can determine the list of items in the picker.  Hence the logic
  // is spread across two functions
  [self finishDisplayingDrawerCell:[self drawerCellForTableView:tableView]];

  if (!sameCellClicked) {
    // After experimenting, it seems this needs to be outside of the beginUpdates/endUpdates
    // in order for setting focus to completely work. If this were placed in the similar
    // if block above, the last row's focus would not get set properly.
    [tableView scrollToRowAtIndexPath:indexPath
                     atScrollPosition:UITableViewScrollPositionTop
                             animated:YES];
  }
}

- (void)finishDisplayingDrawerCell:(UITableViewCell *)cell
{
  assert(YES);
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger numRows = [[self ingredientData] count];

  if ([self drawerIsOpen]) {
    numRows += 1;
  }

  return numRows;
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  assert(YES);
}

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData
{
  assert(YES);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellID = INGREDIENT_ADDITION_CELL;

  if ([self drawerIsAtIndex:indexPath]) {
    cellID = DRAWER_CELL;
  }

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

  if (![self drawerIsAtIndex:indexPath]) {
    id ingredientData = [self ingredientAtIndexPath:indexPath];
    [self populateIngredientCell:cell withIngredientData:ingredientData];
  } else {
    id ingredientData = [self ingredientForDrawer];
    [self populateDrawerCell:cell withIngredientData:ingredientData];
  }
  
  return cell;
}

- (BOOL)isDrawerIndexPath:(NSIndexPath *)indexPath
{
  return self.drawerIndexPath && ([self.drawerIndexPath compare:indexPath] == NSOrderedSame);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return ![self isDrawerIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
  return ![self isDrawerIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    id<OBIngredientAddition> ingredientToRemove = [self ingredientAtIndexPath:indexPath];
    [ingredientToRemove removeFromRecipe];

    int i = 0;
    for (id<OBIngredientAddition> ingredientAddition in [self ingredientData]) {
      [ingredientAddition setDisplayOrder:[NSNumber numberWithInt:i]];
      i++;
    }

    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
  }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  NSMutableArray *data = [NSMutableArray arrayWithArray:[self ingredientData]];
  id<OBIngredientAddition> toMove = data[sourceIndexPath.row];
  [data removeObjectAtIndex:sourceIndexPath.row];
  [data insertObject:toMove atIndex:destinationIndexPath.row];

  int i = 0;
  for (id<OBIngredientAddition> ingredient in data) {
    [ingredient setDisplayOrder:[NSNumber numberWithInt:i]];
    i++;
  }
}


@end
