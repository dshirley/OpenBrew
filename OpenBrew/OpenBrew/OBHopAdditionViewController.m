//
//  OBHopAdditionViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopAdditionViewController.h"
#import "OBIngredientGauge.h"
#import "OBIngredientFinderViewController.h"
#import "OBRecipe.h"
#import "OBHops.h"
#import "OBHopAddition.h"
#import "OBHopAdditionTableViewCell.h"
#import "OBMultiPickerTableViewCell.h"
#import <math.h>

static NSString *const INGREDIENT_ADDITION_CELL = @"IngredientAddition";
static NSString *const DRAWER_CELL = @"DrawerCell";

#define PICKER_TAG 42

@interface OBHopAdditionViewController ()

@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (assign) NSInteger drawerCellRowHeight;
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;

@end

@implementation OBHopAdditionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)loadView {
  [super loadView];
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
  float ibu = [self.recipe IBUs];
  _gauge.value.text = [NSString stringWithFormat:@"%d", (int) round(ibu)];
  _gauge.description.text = @"IBUs";

  [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"addHops"]) {

    OBIngredientFinderViewController *next = [segue destinationViewController];

    NSManagedObjectContext *moc = self.recipe.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Hops"
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

// TODO: duplicate code except with hops instead of malts... not too egregious, though
- (void)ingredientSelected:(UIStoryboardSegue *)unwindSegue
{
  if ([[unwindSegue identifier] isEqualToString:@"IngredientSelected"]) {
    OBIngredientFinderViewController *finderView = [unwindSegue sourceViewController];
    OBHops *hopVariety = [finderView selectedIngredient];
    OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:hopVariety];

    NSUInteger numberOfHops = [[self.recipe hopAdditions] count];

    // TODO: this will become wrong if there are multiple sections for hops
    hopAddition.displayOrder = [NSNumber numberWithUnsignedInteger:numberOfHops];

    [self.recipe addHopAdditionsObject:hopAddition];

    [self reload];
  }
}

#pragma mark - Utility

/**
 * Returns the hops in this recipe in an array format that represents the order
 * of elements in the table view.
 */
- (NSArray *)hopsData {
  NSSortDescriptor *sortByDisplayOrder;

  sortByDisplayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder"
                                                   ascending:YES];

  NSArray *sortSpecification = @[ sortByDisplayOrder ];

  return [[self.recipe hopAdditions] sortedArrayUsingDescriptors:sortSpecification];
}

/**
 * Lookup the hop addition at the given index in the UITableView
 */
- (OBHopAddition *)hopAdditionAtIndexPath:(NSIndexPath *)indexPath
{
  // There can't be a hop addition in the same index as the drawer
  assert(!self.drawerIndexPath || self.drawerIndexPath.row != indexPath.row);

  NSArray *hops = [self hopsData];

  NSUInteger hopsIndex = indexPath.row;
  if ([self drawerIsOpen] && self.drawerIndexPath.row < indexPath.row) {
    hopsIndex -= 1;
  }

  return hops[hopsIndex];
}

- (OBHopAddition *)hopAdditionForDrawer
{
  NSInteger cellRow = self.drawerIndexPath.row - 1;
  NSIndexPath *cellBeforeDrawer = [NSIndexPath indexPathForRow:cellRow inSection:0];

  return [self hopAdditionAtIndexPath:cellBeforeDrawer];
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

  UITableViewCell *pickerCell = [tableView cellForRowAtIndexPath:[self drawerIndexPath]];
  UIPickerView *picker = (UIPickerView *)[pickerCell viewWithTag:PICKER_TAG];
  assert(picker);

  OBHopAddition *hopAddition = [self hopAdditionForDrawer];
  int row = (int) ([hopAddition.alphaAcidPercent floatValue] * 10);

  [picker selectRow:row inComponent:0 animated:NO];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger numRows = self.recipe.hopAdditions.count;

  if ([self drawerIsOpen]) {
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
    // This is a regular hop addition cell.
    OBHopAddition *hopAddition = [self hopAdditionAtIndexPath:indexPath];
    OBHopAdditionTableViewCell *hopCell = (OBHopAdditionTableViewCell *)cell;

    hopCell.hopVariety.text = hopAddition.hops.name;

    float alphaAcids = [hopAddition.alphaAcidPercent floatValue];
    hopCell.alphaAcid.text = [NSString stringWithFormat:@"%.2f%%", alphaAcids];

    float quantityInOunces = [hopAddition.quantityInOunces floatValue];
    hopCell.quantity.text = [NSString stringWithFormat:@"%.2f", quantityInOunces];

    NSInteger boilMinutes = [hopAddition.boilTimeInMinutes integerValue];
    hopCell.boilTime.text = [NSString stringWithFormat:@"%d", boilMinutes];

    hopCell.boilUnits.text = @"min";
  }

  return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // FIXME: remove item from the model, too
    OBHopAddition *hopsToRemove = [self hopAdditionAtIndexPath:indexPath];
    [self.recipe removeHopAdditionsObject:hopsToRemove];

    int i = 0;
    for (OBHopAddition *hops in [self hopsData]) {
      [hops setDisplayOrder:[NSNumber numberWithInt:i]];
      i++;
    }

    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
  }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  NSMutableArray *hopData = [NSMutableArray arrayWithArray:[self hopsData]];
  OBHopAddition *hopsToMove = hopData[sourceIndexPath.row];
  [hopData removeObjectAtIndex:sourceIndexPath.row];
  [hopData insertObject:hopsToMove atIndex:destinationIndexPath.row];

  int i = 0;
  for (OBHopAddition *hops in hopData) {
    [hops setDisplayOrder:[NSNumber numberWithInt:i]];
    i++;
  }
}

#pragma mark - UIPickerViewDataSource Methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  // 10 = number of decimal places; 20 = max alpha acid
  return 10 * 20;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  return [NSString stringWithFormat:@"%.2f%%", (float)row * 0.1];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  float alphaAcid = (float) row / 10;

  [[self hopAdditionForDrawer] setAlphaAcidPercent:[NSNumber numberWithFloat:alphaAcid]];

  [self reload];
}

@end
