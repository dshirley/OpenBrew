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
  OBBatchSizeCellFinalVolumeOfBeer,
  OBBatchSizeCellKettleLossage,
  OBBatchSizeCellFermentorLossage,
  OBBatchSizeCellBoilOff
};

NSString * const OBBatchSizeCellStrings[] = {
  [OBBatchSizeCellFinalVolumeOfBeer] = @"Final beer volume",
  [OBBatchSizeCellKettleLossage] = @"Kettle lossage",
  [OBBatchSizeCellFermentorLossage] = @"Fermentor lossage",
  [OBBatchSizeCellBoilOff] = @"Boil off"
};

@interface OBBatchSizeTableViewDelegate()
@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) OBVolumePickerDelegate *batchSizePickerDelegate;
@property (nonatomic, strong) OBVolumePickerDelegate *boilOffPickerDelegate;
@property (nonatomic, strong) OBVolumePickerDelegate *fermentorLosagePickerDelegate;
@property (nonatomic, strong) OBVolumePickerDelegate *kettleLossagePickerDelegate;

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
    self.batchSizePickerDelegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                                andPropertyGetter:@selector(desiredBeerVolumeInGallons)
                                                                andPropertySetter:@selector(setDesiredBeerVolumeInGallons:)
                                                                      andObserver:self];

    self.boilOffPickerDelegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                              andPropertyGetter:@selector(boilOffInGallons)
                                                              andPropertySetter:@selector(setBoilOffInGallons:)
                                                                    andObserver:self];

    self.fermentorLosagePickerDelegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                                      andPropertyGetter:@selector(fermentorLossageInGallons)
                                                                      andPropertySetter:@selector(setFermentorLossageInGallons:)
                                                                            andObserver:self];

    self.kettleLossagePickerDelegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                                    andPropertyGetter:@selector(kettleLossageInGallons)
                                                                    andPropertySetter:@selector(setKettleLossageInGallons:)
                                                                          andObserver:self];

    self.pickersThatHaveChanged = [NSMutableSet set];
  }

  return self;
}

#pragma mark OBDrawerTableViewDelegate template methods

- (NSArray *)ingredientData {
  return @[ @[ @(OBBatchSizeCellFinalVolumeOfBeer) ],
            @[ @(OBBatchSizeCellKettleLossage),
               @(OBBatchSizeCellFermentorLossage),
               @(OBBatchSizeCellBoilOff) ]];
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  NSNumber *volume = nil;
  NSString *description = nil;

  int idx = [ingredientData intValue];


  switch (idx) {
    case OBBatchSizeCellFinalVolumeOfBeer:
      description = @"Final beer volume";
      volume = self.recipe.desiredBeerVolumeInGallons;
      break;
    case OBBatchSizeCellKettleLossage:
      description = @"Kettle lossage";
      volume = self.recipe.kettleLossageInGallons;
      break;
    case OBBatchSizeCellFermentorLossage:
      description = @"Fermentor lossage";
      volume = self.recipe.fermentorLossageInGallons;
      break;
    case OBBatchSizeCellBoilOff:
      description = @"Boil off";
      volume = self.recipe.boilOffInGallons;
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
    case OBBatchSizeCellFinalVolumeOfBeer:
      pickerDelegate = self.batchSizePickerDelegate;
      break;
    case OBBatchSizeCellKettleLossage:
      pickerDelegate = self.kettleLossagePickerDelegate;
      break;
    case OBBatchSizeCellFermentorLossage:
      pickerDelegate = self.fermentorLosagePickerDelegate;
      break;
    case OBBatchSizeCellBoilOff:
      pickerDelegate = self.batchSizePickerDelegate;
      break;
    default:
      NSAssert(YES, @"Bad index: %d", (int) cellType);
  }

  return pickerDelegate;
}

#pragma mark OBPickerDelegate methods

- (void)pickerChanged
{
  if (![self drawerIsOpen]) {
    // This can get called if a picker is still spinning when the drawer is closed.
    // When it finally lands on a number, some code will get triggered to update the
    // cell.  This should just be ignored.
    return;
  }

  OBMultiPickerTableViewCell *cell = (OBMultiPickerTableViewCell *)[self cellBeforeDrawerForTableView:self.tableView];
  id volumeInfo = [self ingredientForDrawer];
  [self populateIngredientCell:cell withIngredientData:volumeInfo];

  NSString *metricName = cell.textLabel.text;
  if (![self.pickersThatHaveChanged containsObject:metricName]) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:self.gaCategory
                                                          action:metricName
                                                           label:nil
                                                           value:nil] build]];
    [self.pickersThatHaveChanged addObject:metricName];
  }
}


@end
