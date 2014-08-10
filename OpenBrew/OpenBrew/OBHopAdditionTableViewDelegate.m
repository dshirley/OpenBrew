//
//  OBHopAdditionTableViewDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopAdditionTableViewDelegate.h"

#import "OBHopAddition.h"
#import "OBRecipe.h"
#import "OBHops.h"

#import "OBMultiPickerTableViewCell.h"
#import "OBHopAdditionTableViewCell.h"

#import "OBAlphaAcidPickerDelegate.h"
#import "OBHopQuantityPickerDelegate.h"
#import "OBHopBoilTimePickerDelegate.h"

#define ALPHA_ACID_SEGMENT_ID 0
#define QUANTITY_SEGMENT_ID 1
#define BOIL_TIME_SEGMENT_ID 2

@interface OBHopAdditionTableViewDelegate()

@property (nonatomic, retain) OBRecipe *recipe;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) OBAlphaAcidPickerDelegate *alphaAcidPickerDelegate;
@property (nonatomic, strong) OBHopQuantityPickerDelegate *hopQuantityPickerDelegate;
@property (nonatomic, strong) OBHopBoilTimePickerDelegate *hopBoilTimeDelegate;

@end

@implementation OBHopAdditionTableViewDelegate

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView
{
  self = [super init];

  if (self) {
    self.recipe = recipe;
    self.tableView = tableView;

    self.alphaAcidPickerDelegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:nil andObserver:self];
    self.hopQuantityPickerDelegate = [[OBHopQuantityPickerDelegate alloc] initWithHopAddition:nil andObserver:self];
    self.hopBoilTimeDelegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:nil andObserver:self];
  }

  return self;
}

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

#pragma mark - Drawer Management Methods

- (void)segmentSelected:(id)sender
{
  id pickerDelegate = [self pickerDelegateForSegmentControl:sender];
  OBHopAddition *hopAddition = [self ingredientForDrawer];

  [pickerDelegate setHopAddition:hopAddition];

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

- (void)pickerChanged
{
  OBMultiPickerTableViewCell *cell = (OBMultiPickerTableViewCell *)[self cellBeforeDrawerForTableView:self.tableView];
  OBHopAddition *hopAddition = [self ingredientForDrawer];
  [self populateIngredientCell:cell withIngredientData:hopAddition];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    id ingredientToRemove = [self ingredientAtIndexPath:indexPath];

    [self.recipe removeHopAdditionsObject:ingredientToRemove];

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
