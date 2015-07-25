//
//  OBDrawerTableViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/6/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"
#import "OBIngredientAddition.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

// Setting up a table with this data source class requires using the following
// naming conventions for reuse identifiers. While these could be passed in as
// properties to the class, this keeps things consistent.  The downside is that
// it is somewhat arbitrary and things break when the convention isn't followed.
static NSString *const INGREDIENT_ADDITION_CELL = @"IngredientAddition";
static NSString *const DRAWER_CELL = @"DrawerCell";

@interface OBDrawerTableViewDelegate ()
@property (assign) NSInteger drawerCellRowHeight;
@end

@implementation OBDrawerTableViewDelegate

- (id)initWithGACategory:(NSString *)gaCategory;
{
  self = [super init];

  if (self) {
    self.gaCategory = gaCategory;

    // Really dumb way to get the default height of a UIPickerView
    // Apple doesn't provide a constant, though, and the default shown in
    // Interface Builder is wrong (it says 162.  For iOS 7 it is 216)
    UIPickerView *picker = [[UIPickerView alloc] init];
    self.drawerCellRowHeight = picker.frame.size.height;
  }

  return self;
}

/**
 * Lookup the hop addition at the given index in the UITableView
 */
- (id<OBIngredientAddition>)ingredientAtIndexPath:(NSIndexPath *)indexPath
{
  // There can't be an ingredient in the same index as the drawer
  NSAssert(!self.drawerIndexPath || ![self.drawerIndexPath isEqual:indexPath],
           @"drawerIndexPath:%@ indexPath:%@", self.drawerIndexPath, indexPath);

  NSArray *data = [self ingredientData];

  NSUInteger row = indexPath.row;
  if ([self drawerIsOpen] &&
      self.drawerIndexPath.section == indexPath.section &&
      self.drawerIndexPath.row < indexPath.row)
  {
    row -= 1;
  }

  return data[indexPath.section][row];
}

- (NSIndexPath *)indexPathOfCellBeforeDrawer
{
  NSInteger cellRow = self.drawerIndexPath.row - 1;
  NSIndexPath *cellBeforeDrawerIndex = [NSIndexPath indexPathForRow:cellRow
                                                          inSection:self.drawerIndexPath.section];
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
  return ([self drawerIsOpen] && [self.drawerIndexPath isEqual:indexPath]);
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

#pragma mark - Template Methods

- (NSArray *)ingredientData {
  [NSException raise:@"Unimplemented Method"
              format:@"Subclasses must implement ingredientData"];
  return nil;
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  [NSException raise:@"Unimplemented Method"
              format:@"Subclasses must implement populateIngredientCell:withIngredientData:"];
}

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData
{
  [NSException raise:@"Unimplemented Method"
              format:@"Subclasses must implement populateDrawerCell:withIngredientData:"];
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
  BOOL sameCellClicked = (self.drawerIndexPath.row - 1 == indexPath.row) && (self.drawerIndexPath.section == indexPath.section);

  if ([self drawerIsOpen]) {
    // Close the old drawer if one is open
    before = (self.drawerIndexPath.section == indexPath.section) && (self.drawerIndexPath.row < indexPath.row);
    [self closeDrawerForTableView:tableView];
  }

  if (!sameCellClicked) {
    // Open the new drawer
    NSInteger row = (before ? indexPath.row : indexPath.row + 1);
    [self tableView:tableView openDrawerAtRow:row inSection:indexPath.section];
  }

  [tableView endUpdates];

  if (!sameCellClicked) {
    // After experimenting, it seems this needs to be outside of the beginUpdates/endUpdates
    // in order for setting focus to completely work. If this were placed in the similar
    // if block above, the last row's focus would not get set properly.
    [tableView scrollToRowAtIndexPath:indexPath
                     atScrollPosition:UITableViewScrollPositionTop
                             animated:YES];
  }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [[self ingredientData] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger numRows = [[self ingredientData][section] count];

  if ([self drawerIsOpen] && (self.drawerIndexPath.section == section)) {
    numRows += 1;
  }

  return numRows;
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
    for (id<OBIngredientAddition> ingredientAddition in [self ingredientData][indexPath.section]) {
      [ingredientAddition setDisplayOrder:[NSNumber numberWithInt:i]];
      i++;
    }

    if ([self drawerIsOpen] && ((self.drawerIndexPath.row - 1) == indexPath.row) && (self.drawerIndexPath.section == indexPath.section)) {
      // The cell with the drawer has been removed. We need to remove the drawer, too.
      [self closeDrawerForTableView:tableView];
    }

    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];

    if ([self drawerIsOpen] &&
        (self.drawerIndexPath.section == indexPath.section) &&
        (indexPath.row < self.drawerIndexPath.row))
    {
      self.drawerIndexPath = [self indexPathOfCellBeforeDrawer];
      [tableView reloadData];
    }

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:self.gaCategory
                                                          action:@"Delete"
                                                           label:nil
                                                           value:nil] build]];
  }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  NSAssert(![self drawerIsOpen], @"Drawer must be closed before moving rows");
  
  NSMutableArray *data = [NSMutableArray arrayWithArray:[self ingredientData][sourceIndexPath.section]];
  id<OBIngredientAddition> toMove = data[sourceIndexPath.row];
  [data removeObjectAtIndex:sourceIndexPath.row];
  [data insertObject:toMove atIndex:destinationIndexPath.row];

  int i = 0;
  for (id<OBIngredientAddition> ingredient in data) {
    [ingredient setDisplayOrder:[NSNumber numberWithInt:i]];
    i++;
  }

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:self.gaCategory
                                                        action:@"Move"
                                                         label:nil
                                                         value:nil] build]];
}


@end
