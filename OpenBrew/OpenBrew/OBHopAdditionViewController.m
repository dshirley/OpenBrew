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
#import "OBAlphaAcidPickerDelegate.h"
#import "OBHopQuantityPickerDelegate.h"
#import "OBHopBoilTimePickerDelegate.h"
#import "OBPickerDelegate.h"
#import <math.h>

static NSString *const INGREDIENT_ADDITION_CELL = @"IngredientAddition";
static NSString *const DRAWER_CELL = @"DrawerCell";

#define ALPHA_ACID_SEGMENT_ID 0
#define QUANTITY_SEGMENT_ID 1
#define BOIL_TIME_SEGMENT_ID 2

@interface OBHopAdditionViewController ()

@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (assign) NSInteger drawerCellRowHeight;
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;

@property (nonatomic, strong) OBAlphaAcidPickerDelegate *alphaAcidPickerDelegate;
@property (nonatomic, strong) OBHopQuantityPickerDelegate *hopQuantityPickerDelegate;
@property (nonatomic, strong) OBHopBoilTimePickerDelegate *hopBoilTimeDelegate;
@end

@implementation OBHopAdditionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)loadView {
  [super loadView];

  if (!self.alphaAcidPickerDelegate) {
    self.alphaAcidPickerDelegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:nil andObserver:self];
  }

  if (!self.hopQuantityPickerDelegate) {
    self.hopQuantityPickerDelegate = [[OBHopQuantityPickerDelegate alloc] initWithHopAddition:nil andObserver:self];
  }

  if (!self.hopBoilTimeDelegate) {
    self.hopBoilTimeDelegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:nil andObserver:self];
  }
  
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

- (OBMultiPickerTableViewCell *)drawerCell
{
  OBMultiPickerTableViewCell *multiCell = nil;

  if ([self drawerIsOpen]) {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self drawerIndexPath]];
    multiCell = (OBMultiPickerTableViewCell *) cell;
  }

  return multiCell;
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

#pragma mark - Drawer Management Methods

- (void)segmentSelected:(id)sender
{
  id pickerDelegate = [self pickerDelegateForSegmentControl:sender];
  OBHopAddition *hopAddition = [self hopAdditionForDrawer];

  [pickerDelegate setHopAddition:hopAddition];

  OBMultiPickerTableViewCell *multiCell = [self drawerCell];
  multiCell.picker.delegate = pickerDelegate;
  multiCell.picker.dataSource = pickerDelegate;

  // TODO: perhaps combine these methods
  [self updatePickerForTableView:self.tableView];
}

- (id)pickerDelegateForSegmentControl:(UISegmentedControl *)segmentControl
{
  NSInteger segmentId = segmentControl.selectedSegmentIndex;
  id pickerDelegate = nil;

  switch (segmentId) {
    case ALPHA_ACID_SEGMENT_ID:
      pickerDelegate = self.alphaAcidPickerDelegate;
      break;
    case QUANTITY_SEGMENT_ID:
      pickerDelegate = self.hopQuantityPickerDelegate;
      break;
    case BOIL_TIME_SEGMENT_ID:
      pickerDelegate = self.hopBoilTimeDelegate;
      break;
    default:
      NSLog(@"ERROR: Bad segment ID: %d", segmentId);
      assert(NO);
  }

  return pickerDelegate;
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
  [self updatePickerForTableView:tableView];
}

- (void)updatePickerForTableView:(UITableView *)tableView
{
  if (![self drawerIsOpen]) {
    return;
  }

  OBMultiPickerTableViewCell *multiCell = [self drawerCell];
  id<OBPickerDelegate> pickerDelegate = (id<OBPickerDelegate>) multiCell.picker.delegate;

  [pickerDelegate updateSelectionForPicker:multiCell.picker];
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
    hopCell.alphaAcid.text = [NSString stringWithFormat:@"%.1f%%", alphaAcids];

    float quantityInOunces = [hopAddition.quantityInOunces floatValue];
    hopCell.quantity.text = [NSString stringWithFormat:@"%.1f oz", quantityInOunces];

    NSInteger boilMinutes = [hopAddition.boilTimeInMinutes integerValue];
    hopCell.boilTime.text = [NSString stringWithFormat:@"%d", boilMinutes];

    hopCell.boilUnits.text = @"min";
  } else {
    OBHopAddition *hopAddition = [self hopAdditionForDrawer];

    OBMultiPickerTableViewCell *multiCell = (OBMultiPickerTableViewCell *)cell;

    [multiCell.selector addTarget:self
                           action:@selector(segmentSelected:)
                 forControlEvents:UIControlEventValueChanged];

    id pickerDelegate = [self pickerDelegateForSegmentControl:multiCell.selector];

    [pickerDelegate setHopAddition:hopAddition];

    multiCell.picker.delegate = pickerDelegate;
    multiCell.picker.dataSource = pickerDelegate;
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

- (void)pickerChanged
{
  [self reload];
}

@end
