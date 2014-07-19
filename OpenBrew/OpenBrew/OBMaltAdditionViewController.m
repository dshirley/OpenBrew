//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionViewController.h"
#import "OBIngredientFinderViewController.h"

#import "OBMaltAddition.h"

#define LEFT_PICKER_COMPONENT 0
#define RIGHT_PICKER_COMPONENT 1

static NSString *const INGREDIENT_ADDITION_CELL = @"IngredientAddition";
static NSString *const MALT_PICKER_CELL = @"MaltQuantityPicker";

#define PICKER_TAG 42

@interface OBMaltAdditionViewController ()

@property (nonatomic, strong) NSIndexPath *pickerIndexPath;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (assign) NSInteger pickerCellRowHeight;

- (void)updatePickerForTableView:(UITableView *)tableView;

- (void)displayInlinePickerForRowAtIndexPath:(NSIndexPath *)indexPath
                                    forTable:(UITableView *)tableView;

- (void)reload;

@end

@implementation OBMaltAdditionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
      
        // Custom initialization
    }
    return self;
}

- (void)loadView {
  [super loadView];
  [self reload];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  // Really dumb way to get the default height of a UIPickerView
  // Apple doesn't provide a constant, though, and the default shown in
  // Interface Builder is wrong (it says 162.  For iOS 7 it is 216)
  UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 77, 320, 0)];
  self.pickerCellRowHeight = picker.frame.size.height;

  [self reload];
}

- (void)reload {
  float gravity = [self.recipe originalGravity];
  _gauge.value.text = [NSString stringWithFormat:@"%.3f", gravity];
  _gauge.description.text = @"Estimated Starting Gravity";

  [_ingredientTable reloadData];
}

#pragma mark - Segues

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
  // There can't be a malt addition in the same index as the UIPickerView
  assert(!self.pickerIndexPath || self.pickerIndexPath.row != indexPath.row);

  NSArray *malts = [self maltData];

  NSUInteger maltIndex = indexPath.row;
  if ([self hasInlinePicker] && self.pickerIndexPath.row < indexPath.row) {
    maltIndex -= 1;
  }

  return malts[maltIndex];
}

- (OBMaltAddition *)maltAdditionForPicker
{
  NSInteger cellRow = self.pickerIndexPath.row - 1;
  NSIndexPath *cellBeforePicker = [NSIndexPath indexPathForRow:cellRow inSection:0];

  return [self maltAdditionAtIndexPath:cellBeforePicker];
}

- (BOOL)hasInlinePicker
{
  return (self.pickerIndexPath != nil);
}

- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
  return ([self hasInlinePicker] && self.pickerIndexPath.row == indexPath.row);
}


- (UIPickerView *)pickerAtIndexPath:(NSIndexPath *)indexPath
                           andTable:(UITableView *)tableView
{
  UIPickerView *picker = nil;

  if (indexPath) {
    UITableViewCell *pickerCell = [tableView cellForRowAtIndexPath:indexPath];

    picker = (UIPickerView *)[pickerCell viewWithTag:PICKER_TAG];
  }

  return picker;
}

#pragma mark - UITableViewDelegate Methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

  if ([cell.reuseIdentifier isEqualToString:INGREDIENT_ADDITION_CELL]) {
    [self displayInlinePickerForRowAtIndexPath:indexPath forTable:tableView];
  } else {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

- (void)displayInlinePickerForRowAtIndexPath:(NSIndexPath *)indexPath
                                    forTable:(UITableView *)tableView
{
  [tableView beginUpdates];

  // indicates if the date picker is below "indexPath", help us determine which row to reveal
  BOOL before = NO;

  if ([self hasInlinePicker]) {
    before = self.pickerIndexPath.row < indexPath.row;
  }

  BOOL sameCellClicked = (self.pickerIndexPath.row - 1 == indexPath.row);

  // remove any date picker cell if it exists
  if ([self hasInlinePicker]) {
    [tableView deleteRowsAtIndexPaths:@[self.pickerIndexPath]
                     withRowAnimation:UITableViewRowAnimationFade];

    self.pickerIndexPath = nil;
  }

  if (!sameCellClicked) {
    // hide the old date picker and display the new one
    NSInteger rowToAddPicker = (before ? indexPath.row : indexPath.row + 1);
    NSIndexPath *indexToAddPicker = [NSIndexPath indexPathForRow:rowToAddPicker
                                                       inSection:0];

    [tableView insertRowsAtIndexPaths:@[indexToAddPicker]
                     withRowAnimation:UITableViewRowAnimationFade];

    self.pickerIndexPath = indexToAddPicker;
  }

  // always deselect the row containing the start or end date
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  [tableView endUpdates];

  [self updatePickerForTableView:tableView];
}

- (void)updatePickerForTableView:(UITableView *)tableView
{
  UIPickerView *picker = [self pickerAtIndexPath:self.pickerIndexPath andTable:tableView];

  if (picker) {
    OBMaltAddition *maltAddition = [self maltAdditionForPicker];
    NSInteger baseRow = 16 * 5000;
    float pounds = [[maltAddition quantityInPounds] floatValue];
    float ounces = trunc((pounds - trunc(pounds)) * 16);

    [picker selectRow:(baseRow + ounces) inComponent:RIGHT_PICKER_COMPONENT animated:NO];
    [picker selectRow:(trunc(pounds)) inComponent:LEFT_PICKER_COMPONENT animated:NO];
  }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  NSInteger numRows = self.recipe.maltAdditions.count;

  if ([self hasInlinePicker]) {
    numRows += 1;
  }

  return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellID = INGREDIENT_ADDITION_CELL;

  if ([self indexPathHasPicker:indexPath]) {
    cellID = MALT_PICKER_CELL;
  }

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

  if (![self indexPathHasPicker:indexPath]) {
    OBMaltAddition *maltAddition = [self maltAdditionAtIndexPath:indexPath];

    [[cell textLabel] setText:[maltAddition name]];
    [[cell detailTextLabel] setText:[maltAddition quantityText]];
  }

  return cell;
}

#pragma mark - UIPickerViewDataSource Methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  NSInteger numRows = 0;

  switch (component) {
    case LEFT_PICKER_COMPONENT:
      numRows = 50;
      break;
    case RIGHT_PICKER_COMPONENT:
      numRows = 16 * 10000;
      break;
    default:
      assert(component < 2);
  }

  return numRows;
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)poundsForRow:(NSInteger)row
{
  return row;
}

- (NSInteger)ouncesForRow:(NSInteger)row
{
  return row % 16;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  NSString *text = nil;

  if (component == 0) {
    text = [NSString stringWithFormat:@"%ld lb", (long)[self poundsForRow:row]];
  } else {
    text = [NSString stringWithFormat:@"%ld oz", (long)[self ouncesForRow:row]];
  }

  return text;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  OBMaltAddition *maltAddition = [self maltAdditionForPicker];
  float currentQuantity = [maltAddition.quantityInPounds floatValue];

  if (component == LEFT_PICKER_COMPONENT) {

    float newPounds = (float) [self poundsForRow:row];
    float currentOunces = currentQuantity - trunc(currentQuantity);

    maltAddition.quantityInPounds = [NSNumber numberWithFloat:newPounds + currentOunces];

  } else if (component == RIGHT_PICKER_COMPONENT) {

    float newOunces = ((float) [self ouncesForRow:row]) / 16;
    float currentPounds = trunc(currentQuantity);

    maltAddition.quantityInPounds = [NSNumber numberWithFloat:currentPounds + newOunces];
  }

  [self reload];
}

@end
