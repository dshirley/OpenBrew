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
  OBBatchSizeCell cellType = [ingredientData intValue];
  id<OBPickerDelegate> pickerDelegate = nil;

  [drawerCell.multiPickerView removeAllPickers];

  if (cellType == OBBatchSizeCellPreBoilVolume) {
    pickerDelegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                 recipePropertyName:@"preBoilVolumeInGallons"];

  } else if (cellType == OBBatchSizeCellPostBoilVolume) {
    pickerDelegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                 recipePropertyName:@"postBoilVolumeInGallons"];

  } else {
    [NSException raise:@"Invalid OBBatchSizeCell" format:@"Cell: %@", @(cellType)];
  }

  [drawerCell.multiPickerView addPickerDelegate:pickerDelegate withTitle:@"unused"];
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

@end
