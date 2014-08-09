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

#define ALPHA_ACID_SEGMENT_ID 0
#define QUANTITY_SEGMENT_ID 1
#define BOIL_TIME_SEGMENT_ID 2

@interface OBHopAdditionViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;

@property (nonatomic, strong) OBAlphaAcidPickerDelegate *alphaAcidPickerDelegate;
@property (nonatomic, strong) OBHopQuantityPickerDelegate *hopQuantityPickerDelegate;
@property (nonatomic, strong) OBHopBoilTimePickerDelegate *hopBoilTimeDelegate;
@end

@implementation OBHopAdditionViewController

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

- (void)reload {
  [super reload];

  float ibu = [self.recipe IBUs];
  _gauge.value.text = [NSString stringWithFormat:@"%d", (int) round(ibu)];
  _gauge.description.text = @"IBUs";
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
- (NSArray *)ingredientData {
  NSSortDescriptor *sortByDisplayOrder;

  sortByDisplayOrder = [[NSSortDescriptor alloc] initWithKey:@"displayOrder"
                                                   ascending:YES];

  NSArray *sortSpecification = @[ sortByDisplayOrder ];

  return [[self.recipe hopAdditions] sortedArrayUsingDescriptors:sortSpecification];
}


#pragma mark - Drawer Management Methods

- (void)segmentSelected:(id)sender
{
  id pickerDelegate = [self pickerDelegateForSegmentControl:sender];
  OBHopAddition *hopAddition = [self ingredientForDrawer];

  [pickerDelegate setHopAddition:hopAddition];

  OBMultiPickerTableViewCell *multiCell = (OBMultiPickerTableViewCell *)[self drawerCell];
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
      NSLog(@"ERROR: Bad segment ID: %ld", (long)segmentId);
      assert(NO);
  }

  return pickerDelegate;
}

- (void)finishDisplayingDrawerCell:(UITableViewCell *)cell
{
  if (!cell) {
    return;
  }

  OBMultiPickerTableViewCell *multiCell = (OBMultiPickerTableViewCell *)cell;
  id<OBPickerDelegate> pickerDelegate = (id<OBPickerDelegate>) multiCell.picker.delegate;

  [pickerDelegate updateSelectionForPicker:multiCell.picker];
}

- (void)populateIngredientCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData
{
  OBHopAddition *hopAddition = (OBHopAddition *)ingredientData;
  OBHopAdditionTableViewCell *hopCell = (OBHopAdditionTableViewCell *)cell;

  hopCell.hopVariety.text = hopAddition.hops.name;

  float alphaAcids = [hopAddition.alphaAcidPercent floatValue];
  hopCell.alphaAcid.text = [NSString stringWithFormat:@"%.1f%%", alphaAcids];

  float quantityInOunces = [hopAddition.quantityInOunces floatValue];
  hopCell.quantity.text = [NSString stringWithFormat:@"%.1f oz", quantityInOunces];

  NSInteger boilMinutes = [hopAddition.boilTimeInMinutes integerValue];
  hopCell.boilTime.text = [NSString stringWithFormat:@"%ld", (long)boilMinutes];

  hopCell.boilUnits.text = @"min";
}

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData
{
  OBHopAddition *hopAddition = (OBHopAddition *)ingredientData;

  OBMultiPickerTableViewCell *multiCell = (OBMultiPickerTableViewCell *)cell;

  [multiCell.selector addTarget:self
                         action:@selector(segmentSelected:)
               forControlEvents:UIControlEventValueChanged];

  id pickerDelegate = [self pickerDelegateForSegmentControl:multiCell.selector];

  [pickerDelegate setHopAddition:hopAddition];

  multiCell.picker.delegate = pickerDelegate;
  multiCell.picker.dataSource = pickerDelegate;
}

- (void)removeIngredient:(id)ingredientToRemove fromRecipe:(OBRecipe *)recipe;
{
  [recipe removeHopAdditionsObject:ingredientToRemove];
}

- (void)pickerChanged
{
  [self reload];
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    id ingredientToRemove = [self ingredientAtIndexPath:indexPath];

    [self removeIngredient:ingredientToRemove fromRecipe:self.recipe];

    int i = 0;
    for (id ingredient in [self ingredientData]) {
      [ingredient setDisplayOrder:[NSNumber numberWithInt:i]];
      i++;
    }

    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
  }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
  NSMutableArray *ingredientData = [NSMutableArray arrayWithArray:[self ingredientData]];
  OBHopAddition *ingredientToMove = ingredientData[sourceIndexPath.row];
  [ingredientData removeObjectAtIndex:sourceIndexPath.row];
  [ingredientData insertObject:ingredientToMove atIndex:destinationIndexPath.row];

  int i = 0;
  for (OBHopAddition *ingredient in ingredientData) {
    [ingredient setDisplayOrder:[NSNumber numberWithInt:i]];
    i++;
  }
}

@end
