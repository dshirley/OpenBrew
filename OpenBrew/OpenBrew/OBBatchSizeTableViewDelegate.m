//
//  OBBatchSizeTableViewDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 6/8/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBBatchSizeTableViewDelegate.h"
#import "OBRecipe.h"
#import "OBMultiPickerTableViewCell.h"
#import "OBVolumePickerDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

typedef NS_ENUM(NSInteger, OBBatchSizeCell) {
  OBBatchSizeCellPreBoilVolume,
  OBBatchSizeCellPostBoilVolume
};

NSString * const OBBatchSizeCellStrings[] = {
  [OBBatchSizeCellPreBoilVolume] = @"Pre-boil volume",
  [OBBatchSizeCellPostBoilVolume] = @"Post-boil volume"
};

@interface OBBatchSizeTableViewDelegate()
@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) OBVolumePickerDelegate *preBoilVolumePickerDelegate;
@property (nonatomic, strong) OBVolumePickerDelegate *postBoilVolumePickerDelegate;

// Used for Google Analytics (GA) tracking. We track which metrics are being used, but
// we only need to log one GA event per picker.
@property (nonatomic, strong) NSMutableSet *pickersThatHaveChanged;

@end

@implementation OBBatchSizeTableViewDelegate

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView andGACategory:(NSString *)gaCategory
{
  self = [super initWithGACategory:gaCategory];

  if (self) {
    self.recipe = recipe;
    self.tableView = tableView;
    self.preBoilVolumePickerDelegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                                andPropertyGetter:@selector(preBoilVolumeInGallons)
                                                                andPropertySetter:@selector(setPreBoilVolumeInGallons:)];

    self.postBoilVolumePickerDelegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                              andPropertyGetter:@selector(postBoilVolumeInGallons)
                                                              andPropertySetter:@selector(setPostBoilVolumeInGallons:)];

    self.pickersThatHaveChanged = [NSMutableSet set];
  }

  return self;
}

#pragma mark OBDrawerTableViewDelegate template methods

- (NSArray *)ingredientData {
  return @[ @[ @(OBBatchSizeCellPreBoilVolume),
               @(OBBatchSizeCellPostBoilVolume) ]];
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  NSNumber *volume = nil;
  NSString *description = nil;

  int idx = [ingredientData intValue];


  switch (idx) {
    case OBBatchSizeCellPreBoilVolume:
      description = @"Pre-boil volume";
      volume = self.recipe.preBoilVolumeInGallons;
      break;
    case OBBatchSizeCellPostBoilVolume:
      description = @"Post-boil volume";
      volume = self.recipe.postBoilVolumeInGallons;
      break;
    default:
      NSAssert(YES, @"Bad index: %d", idx);
  }

  cell.textLabel.text = description;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ gal", volume];
}

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData
{
  OBMultiPickerTableViewCell *drawerCell = (OBMultiPickerTableViewCell *)cell;

  UITableViewCell *ingredientCell = [self cellBeforeDrawerForTableView:self.tableView];
  NSIndexPath *indexPathOfIngredient = [self.tableView indexPathForCell:ingredientCell];

  // FIXME: ingredientAtIndexPath returns an OBIngredientAddition... this is being hacked in
  OBBatchSizeCell cellType = [(NSNumber *)[self ingredientAtIndexPath:indexPathOfIngredient] intValue];
  id pickerDelegate = [self pickerDelegateForCellType:cellType];

  drawerCell.picker.delegate = pickerDelegate;
  drawerCell.picker.dataSource = pickerDelegate;
}

- (void)willRemoveDrawerCell:(UITableViewCell *)cell
{
  OBMultiPickerTableViewCell *drawerCell = (OBMultiPickerTableViewCell *)cell;

  drawerCell.picker.delegate = nil;
  drawerCell.picker.dataSource = nil;
}

// TODO: this seems like a duplicate method. Can this go in the parent class?
- (void)finishDisplayingDrawerCell:(UITableViewCell *)cell
{
  if (!cell) {
    return;
  }

  OBMultiPickerTableViewCell *drawerCell = (OBMultiPickerTableViewCell *)cell;
  id<OBPickerDelegate> pickerDelegate = (id<OBPickerDelegate>) drawerCell.picker.delegate;

  [pickerDelegate updateSelectionForPicker:drawerCell.picker];
}

#pragma mark UITableViewDelegate override methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 32; //section == 0 ? 0 : 32;
}

// OBDrawerTableViewDelegate allows editing by default.  Since the content of the
// batch size view controller is static, we don't want this.

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

#pragma mark Picker Management Methods

- (id)pickerDelegateForCellType:(OBBatchSizeCell)cellType
{
  id pickerDelegate = nil;

  switch (cellType) {
    case OBBatchSizeCellPreBoilVolume:
      pickerDelegate = self.preBoilVolumePickerDelegate;
      break;
    case OBBatchSizeCellPostBoilVolume:
      pickerDelegate = self.postBoilVolumePickerDelegate;
      break;
    default:
      NSAssert(YES, @"Bad index: %d", (int) cellType);
  }

  return pickerDelegate;
}

@end
