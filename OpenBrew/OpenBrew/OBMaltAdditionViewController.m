//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionViewController.h"
#import "OBIngredientGauge.h"
#import "OBIngredientFinderViewController.h"
#import "OBRecipe.h"
#import "OBMalt.h"
#import "OBMaltAddition.h"
#import "OBMaltAdditionTableViewCell.h"
#import "OBMultiPickerTableViewCell.h"
#import "OBMaltQuantityPickerDelegate.h"

static NSString *const INGREDIENT_ADDITION_CELL = @"IngredientAddition";
static NSString *const DRAWER_CELL = @"DrawerCell";

@interface OBMaltAdditionViewController ()

@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (assign) NSInteger drawerCellRowHeight;
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, strong) OBMaltQuantityPickerDelegate *maltQuantityPickerDelegate;

@end

@implementation OBMaltAdditionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)loadView {
  [super loadView];

  self.maltQuantityPickerDelegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:nil andObserver:self];

  [self reload];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.navigationItem.rightBarButtonItem = self.editButtonItem;

  // Really dumb way to get the default height of a UIPickerView
  // Apple doesn't provide a constant, though, and the default shown in
  // Interface Builder is wrong (it says 162.  For iOS 7 it is 216)
  UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 77, 320, 0)];
  self.drawerCellRowHeight = picker.frame.size.height;

  [self reload];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
  [super setEditing:editing animated:animated];

  // Get rid of the picker.  It'll get in the way and we don't want users to
  // be able to move it anyways.
  [self.tableView beginUpdates];
  [self closeDrawerForTableView:self.tableView];
  [self.tableView endUpdates];

  [self.tableView setEditing:editing animated:animated];
}

- (void)reload {
  float gravity = [self.recipe originalGravity];
  _gauge.value.text = [NSString stringWithFormat:@"%.3f", gravity];
  _gauge.description.text = @"Estimated Starting Gravity";

  [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"addIngredient"]) {

    OBIngredientFinderViewController *next = [segue destinationViewController];

    NSManagedObjectContext *moc = self.recipe.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Malt"
                                              inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];\

    [request setSortDescriptors:@[sortDescriptor]];

    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];

    assert(array);

    [next setIngredients:array];
  }
}

- (void)ingredientSelected:(UIStoryboardSegue *)unwindSegue
{
  if ([[unwindSegue identifier] isEqualToString:@"IngredientSelected"]) {
    OBIngredientFinderViewController *finderView = [unwindSegue sourceViewController];
    OBMalt *malt = [finderView selectedIngredient];
    OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:malt];

    NSUInteger numberOfMalts = [[self.recipe maltAdditions] count];
    maltAddition.displayOrder = [NSNumber numberWithUnsignedInteger:numberOfMalts];

    [self.recipe addMaltAdditionsObject:maltAddition];

    [self reload];
  }
}

#pragma mark - Utility

/**
 * Returns the malts in this recipe in an array format that represents the order
 * of elements in the table view.
 */
- (NSArray *)maltData {
  NSSortDescriptor *sortByDisplayOrder;

  sortByDisplayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder"
                                                   ascending:YES];

  NSArray *sortSpecification = @[ sortByDisplayOrder ];

  return [[self.recipe maltAdditions] sortedArrayUsingDescriptors:sortSpecification];
}

/**
 * Lookup the malt addition at the given index in the UITableView
 */
- (OBMaltAddition *)maltAdditionAtIndexPath:(NSIndexPath *)indexPath
{
  // There can't be a malt addition in the same index as the drawer
  assert(!self.drawerIndexPath || self.drawerIndexPath.row != indexPath.row);

  NSArray *malts = [self maltData];

  NSUInteger maltIndex = indexPath.row;
  if ([self drawerIsOpen] && self.drawerIndexPath.row < indexPath.row) {
    maltIndex -= 1;
  }

  return malts[maltIndex];
}

- (NSIndexPath *)cellBeforeDrawer
{
  NSInteger cellRow = self.drawerIndexPath.row - 1;
  return [NSIndexPath indexPathForRow:cellRow inSection:0];
}

- (OBMaltAddition *)maltAdditionForDrawer
{
  NSIndexPath *cellBeforeDrawer = [self cellBeforeDrawer];
  return [self maltAdditionAtIndexPath:cellBeforeDrawer];
}

- (BOOL)drawerIsOpen
{
  return (self.drawerIndexPath != nil);
}

- (BOOL)drawerIsAtIndex:(NSIndexPath *)indexPath
{
  return ([self drawerIsOpen] && self.drawerIndexPath.row == indexPath.row);
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

  [self updatePickerForTableView:tableView];
}

- (void)updatePickerForTableView:(UITableView *)tableView
{
  if (![self drawerIsOpen]) {
    return;
  }

  OBMultiPickerTableViewCell *cell = (OBMultiPickerTableViewCell *)[tableView cellForRowAtIndexPath:[self drawerIndexPath]];
  UIPickerView *picker = cell.picker;

  [self.maltQuantityPickerDelegate updateSelectionForPicker:picker];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger numRows = self.recipe.maltAdditions.count;

  if ([self drawerIsOpen]) {
    numRows += 1;
  }

  return numRows;
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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellID = INGREDIENT_ADDITION_CELL;

  if ([self drawerIsAtIndex:indexPath]) {
    cellID = DRAWER_CELL;
  }

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

  if (![self drawerIsAtIndex:indexPath]) {
    OBMaltAddition *maltAddition = [self maltAdditionAtIndexPath:indexPath];
    [self populateIngredientCell:cell withIngredientData:maltAddition];
  } else {

    OBMultiPickerTableViewCell *drawerCell = (OBMultiPickerTableViewCell *)cell;

    // FIXME: hackish casts
    drawerCell.picker.delegate = (id)self.maltQuantityPickerDelegate;
    drawerCell.picker.dataSource = (id)self.maltQuantityPickerDelegate;
    self.maltQuantityPickerDelegate.maltAddition = [self maltAdditionForDrawer];
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // FIXME: remove item from the model, too
    OBMaltAddition *maltToRemove = [self maltAdditionAtIndexPath:indexPath];
    [self.recipe removeMaltAdditionsObject:maltToRemove];

    int i = 0;
    for (OBMaltAddition *malt in [self maltData]) {
      [malt setDisplayOrder:[NSNumber numberWithInt:i]];
      i++;
    }

    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
  }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  NSMutableArray *maltData = [NSMutableArray arrayWithArray:[self maltData]];
  OBMaltAddition *maltToMove = maltData[sourceIndexPath.row];
  [maltData removeObjectAtIndex:sourceIndexPath.row];
  [maltData insertObject:maltToMove atIndex:destinationIndexPath.row];

  int i = 0;
  for (OBMaltAddition *malt in maltData) {
    [malt setDisplayOrder:[NSNumber numberWithInt:i]];
    i++;
  }
}

- (void)pickerChanged
{
  NSIndexPath *index = [self cellBeforeDrawer];
  OBMultiPickerTableViewCell *cell = (OBMultiPickerTableViewCell *)[self.tableView cellForRowAtIndexPath:index];
  OBMaltAddition *maltAddition = [self maltAdditionForDrawer];
  [self populateIngredientCell:cell withIngredientData:maltAddition];
}

@end
