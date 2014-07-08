//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientDashboardController.h"
#import "OBIngredientFinderViewController.h"

#import "OBMaltAddition.h"

#define LEFT_PICKER_COMPONENT 0
#define RIGHT_PICKER_COMPONENT 1

#define PICKER_TAG 42

@interface OBIngredientDashboardController ()

@property (nonatomic, strong) NSIndexPath *quantityPickerIndexPath;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (assign) NSInteger pickerCellRowHeight;

- (void)reload;

@end

@implementation OBIngredientDashboardController

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
  _gauge.value.text = [_delegate gaugeValueForRecipe:_recipe];
  _gauge.description.text = [_delegate gaugeDescriptionText];

  [_addButton setTitle:[_delegate addButtonText] forState:UIControlStateNormal];
  [_ingredientTable reloadData];
}

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

- (BOOL)hasInlinePicker
{
  return (self.quantityPickerIndexPath != nil);
}

- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
  return ([self hasInlinePicker] && self.quantityPickerIndexPath.row == indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
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
  // TODO: make this a constant
  NSString *cellID = @"IngredientAddition";

  if ([self indexPathHasPicker:indexPath]) {
    cellID = @"MaltQuantityPicker";
  }

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];

  if (![self indexPathHasPicker:indexPath]) {
    NSSortDescriptor *sortBySize = [[NSSortDescriptor alloc] initWithKey:@"quantityInPounds"
                                                               ascending:NO];

    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                               ascending:YES];

    NSArray *sortSpecification = @[ sortBySize, sortByName ];

    NSArray *malts = [[self.recipe maltAdditions] sortedArrayUsingDescriptors:sortSpecification];

    NSUInteger maltIndex = indexPath.row;
    if (self.quantityPickerIndexPath.row < indexPath.row) {
      maltIndex -= 1;
    }

    OBMaltAddition *maltAddition = malts[maltIndex];

    [[cell textLabel] setText:[maltAddition name]];
    [[cell detailTextLabel] setText:[maltAddition quantityText]];
  }

  return cell;
}

- (void)updatePickerForTableView:(UITableView *)tableView
{
  if (self.quantityPickerIndexPath) {
    UITableViewCell *associatedPickerCell = [tableView cellForRowAtIndexPath:self.quantityPickerIndexPath];
    UIPickerView *picker = (UIPickerView *)[associatedPickerCell viewWithTag:PICKER_TAG];

    if (picker) {
      [picker selectRow:(16*5000) inComponent:RIGHT_PICKER_COMPONENT animated:NO];
    }
  }
}

- (void)displayInlinePickerForRowAtIndexPath:(NSIndexPath *)indexPath
                                    forTable:(UITableView *)tableView
{
  [tableView beginUpdates];

  // indicates if the date picker is below "indexPath", help us determine which row to reveal
  BOOL before = NO;

  if ([self hasInlinePicker]) {
    before = self.quantityPickerIndexPath.row < indexPath.row;
  }

  BOOL sameCellClicked = (self.quantityPickerIndexPath.row - 1 == indexPath.row);

  // remove any date picker cell if it exists
  if ([self hasInlinePicker]) {
    [tableView deleteRowsAtIndexPaths:@[self.quantityPickerIndexPath]
                     withRowAnimation:UITableViewRowAnimationFade];

    self.quantityPickerIndexPath = nil;
  }

  if (!sameCellClicked) {
    // hide the old date picker and display the new one
    NSInteger rowToAddPicker = (before ? indexPath.row : indexPath.row + 1);
    NSIndexPath *indexToAddPicker = [NSIndexPath indexPathForRow:rowToAddPicker
                                                       inSection:0];

    [tableView insertRowsAtIndexPaths:@[indexToAddPicker]
                     withRowAnimation:UITableViewRowAnimationFade];

    self.quantityPickerIndexPath = indexToAddPicker;
  }

  // always deselect the row containing the start or end date
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  [tableView endUpdates];

  // inform our date picker of the current date to match the current cell
  // TODO: implement me
  // [self updateDatePicker];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

  if ([cell.reuseIdentifier isEqualToString:@"IngredientAddition"]) {
    [self displayInlinePickerForRowAtIndexPath:indexPath forTable:tableView];
  } else {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}


- (void)ingredientSelected:(UIStoryboardSegue *)unwindSegue
{
  if ([[unwindSegue identifier] isEqualToString:@"IngredientSelected"]) {
    OBIngredientFinderViewController *finderView = [unwindSegue sourceViewController];
    id ingredient = [finderView selectedIngredient];
    [self.delegate addIngredient:ingredient toRecipe:self.recipe];
    [self reload];
  }
}

#pragma UIPickerViewDataSource Methods
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

#pragma UIPickerViewDelegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  NSString *text = nil;

  if (component == 0) {
    text = [NSString stringWithFormat:@"%d lb", row];
  } else {
    text = [NSString stringWithFormat:@"%d oz", row % 16];
  }

  return text;
}


@end

@implementation OBMaltDashboardDelegate

- (NSString *)addButtonText {
  return @"Add Malt";
}

- (NSString *)gaugeValueForRecipe:(OBRecipe *)recipe {
  float gravity = [recipe originalGravity];
  return [NSString stringWithFormat:@"%.3f", gravity];
}

- (NSString *)gaugeDescriptionText {
  return @"Estimated Starting Gravity";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
             forRecipe:(OBRecipe *)recipe
{
  return [[recipe maltAdditions] count];
}

- (void)populateCell:(UITableViewCell *)cell
            forIndex:(NSIndexPath *)index
           andRecipe:(OBRecipe *) recipe
{
  NSSortDescriptor *sortBySize = [[NSSortDescriptor alloc] initWithKey:@"quantityInPounds"
                                                             ascending:NO];

  NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];

  NSArray *sortSpecification = @[ sortBySize, sortByName ];

  NSArray *malts = [[recipe maltAdditions] sortedArrayUsingDescriptors:sortSpecification];

  OBMaltAddition *maltAddition = malts[index.row];
  
  [[cell textLabel] setText:[maltAddition name]];
  [[cell detailTextLabel] setText:[maltAddition quantityText]];
}

- (void)addIngredient:(id)ingredient toRecipe:(OBRecipe *)recipe {
  OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:ingredient];
  [recipe addMaltAdditionsObject:maltAddition];

}

@end


@implementation OBHopsDashboardDelegate

- (NSString *)addButtonText {
  return @"Add Hops";
}

- (NSString *)gaugeValueForRecipe:(OBRecipe *)recipe {
  float ibus = [recipe IBUs];
  return [NSString stringWithFormat:@"%.0f", ibus];
}

- (NSString *)gaugeDescriptionText {
  return @"Estimated IBUs";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
             forRecipe:(OBRecipe *)recipe
{
  return 3;
}

- (void)populateCell:(UITableViewCell *)cell
            forIndex:(NSIndexPath *)index
           andRecipe:(OBRecipe *) recipe
{
  [[cell textLabel] setText:@"Hops"];
  [[cell detailTextLabel] setText:@"12"];
}

- (void)addIngredient:(id)ingredient toRecipe:(OBRecipe *)recipe {
  [recipe addHopAdditionsObject:ingredient];
}

@end
