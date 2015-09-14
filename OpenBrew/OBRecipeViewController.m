//
//  OBRecipeViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/26/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipeViewController.h"
#import "OBMaltAdditionViewController.h"
#import "OBYeastAddition.h"
#import "OBYeast.h"
#import "OBBatchSizeViewController.h"
#import "OBHopAdditionViewController.h"
#import "OBBrewController.h"
#import "OBTextStatisticsCollectionViewCell.h"
#import "OBColorStatisticsCollectionViewCell.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "OBMaltAddition.h"
#import "OBHopAddition.h"
#import "OBMalt.h"
#import "OBHops.h"
#import "OBSettings.h"
#import "Crittercism+NSErrorLogging.h"

// Google Analytics event category
static NSString* const OBGAScreenName = @"Recipe Screen";

typedef NS_ENUM(NSInteger, OBRecipeViewCellType) {
  OBBatchSizeCell,
  OBMaltsCell,
  OBHopsCell,
  OBYeastCell,
  OBNumberOfCells
};

typedef NS_ENUM(NSInteger, OBRecipeStatistic) {
  OBOriginalGravity,
  OBFinalGravity,
  OBAbv,
  OBColor,
  OBIbu,
  OBBuToGuRatio,
  OBNumberOfStatistics
};

@implementation OBRecipeViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.hasTriedTapping = NO;

  self.recipeNameTextField.text = self.recipe.name;
  [self addSeparatorToTopOfTableView];
}

- (void)addSeparatorToTopOfTableView
{
  UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
  headerView.backgroundColor = self.tableView.separatorColor;
  self.tableView.tableHeaderView = headerView;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.screenName = OBGAScreenName;

  [self reloadData];

  NSError *error = nil;
  [self.recipe.managedObjectContext save:&error];
  CRITTERCISM_LOG_ERROR(error);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  id<OBBrewController> brewController = segue.destinationViewController;
  [brewController setRecipe:self.recipe];
  [brewController setSettings:self.settings];
}

- (void)reloadData {
  [self.collectionView reloadData];
  [self.tableView reloadData];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self dismissKeyboard];
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  assert(textField == self.recipeNameTextField);

  self.recipe.name = self.recipeNameTextField.text;

  NSError *error = nil;
  [self.recipe.managedObjectContext save:&error];
  CRITTERCISM_LOG_ERROR(error);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return (NSInteger) OBNumberOfCells;
}

- (NSUInteger)numberOfHopVarieties
{
  NSMutableSet *seenHops = [NSMutableSet set];

  for (OBHopAddition *hopAddition in self.recipe.hopAdditions) {
    [seenHops addObject:hopAddition.name];
  }

  return seenHops.count;
}

- (NSUInteger)numberOfMaltVarieties
{
  NSMutableSet *seenMalts = [NSMutableSet set];

  for (OBMaltAddition *maltAddition in self.recipe.maltAdditions) {
    [seenMalts addObject:maltAddition.name];
  }

  return seenMalts.count;
}

- (NSString *)hopAndMaltDetailDisplayValue:(NSUInteger)count
{
  NSString *display = @"none";

  if (count == 1) {
    display = [NSString stringWithFormat:@"%lu variety", (unsigned long)count];
  } else {
    display = [NSString stringWithFormat:@"%lu varieties", (unsigned long)count];
  }

  return display;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell"];
  OBRecipeViewCellType cellType = (OBRecipeViewCellType) indexPath.row;
  NSUInteger count = 0;

  switch (cellType) {
    case OBBatchSizeCell:
      cell.textLabel.text = @"Batch size";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f gallons", [self.recipe.postBoilVolumeInGallons floatValue]];
      break;
    case OBMaltsCell:
      cell.textLabel.text = @"Malts";
      count = [self numberOfMaltVarieties];
      cell.detailTextLabel.text = [self hopAndMaltDetailDisplayValue:count];
      break;
    case OBHopsCell:
      cell.textLabel.text = @"Hops";
      count = [self numberOfHopVarieties];
      cell.detailTextLabel.text = [self hopAndMaltDetailDisplayValue:count];
      break;
    case OBYeastCell:
      cell.textLabel.text = @"Yeast";
      if (self.recipe.yeast) {
        cell.detailTextLabel.text = self.recipe.yeast.name;
      } else {
        cell.detailTextLabel.text = @"none";
      }
      break;
    default:
      CRITTERCISM_LOG_ERROR([NSError errorWithDomain:@"OBRecipeViewController"
                                                code:1002
                                            userInfo:(@{@"row" : @(indexPath.row),
                                                        @"section" : @(indexPath.section)}) ]);
  }

  return cell;
}

- (void)dismissKeyboard
{
  [self.view endEditing:YES];
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  OBRecipeViewCellType cellType = (OBRecipeViewCellType) indexPath.row;

  [self dismissKeyboard];

  // This table is not used for selection. It is used as a table of contents to other views.
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  switch (cellType) {
    case OBBatchSizeCell:
      [self performSegueWithIdentifier:@"selectedBatchSize" sender:self];
      break;
    case OBMaltsCell:
      [self performSegueWithIdentifier:@"selectedMalts" sender:self];
      break;
    case OBHopsCell:
      [self performSegueWithIdentifier:@"selectedHops" sender:self];
      break;
    case OBYeastCell:
      [self performSegueWithIdentifier:@"selectedYeast" sender:self];
      break;
    default:
      CRITTERCISM_LOG_ERROR([NSError errorWithDomain:@"OBRecipeViewController"
                                                code:1000
                                            userInfo:(@{ @"row" : @(indexPath.row),
                                                         @"section" : @(indexPath.section)})]);
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return self.tableView.frame.size.height / [self tableView:tableView numberOfRowsInSection:indexPath.section];
}

#pragma mark UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
  return OBNumberOfStatistics;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  OBRecipeStatistic cellType = (OBRecipeStatistic) indexPath.row;
  UICollectionViewCell *cell = nil;

  if (cellType == OBColor) {
    cell = [self collectionView:collectionView colorStatisticsCellForIndexPath:indexPath];
  } else {
    cell = [self collectionView:collectionView textStatisticsCellForIndexPath:indexPath];
  }

  return cell;
}

- (OBColorStatisticsCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                        colorStatisticsCellForIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorMetric"
                                                                         forIndexPath:indexPath];

  OBColorStatisticsCollectionViewCell *colorCell = (OBColorStatisticsCollectionViewCell *) cell;

  colorCell.colorView.colorInSrm = roundf([self.recipe colorInSRM]);
  colorCell.descriptionLabel.text = @"Color";

  return colorCell;
}

- (OBTextStatisticsCollectionViewCell *)collectionView:(UICollectionView *)collectionView
                        textStatisticsCellForIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"textMetric"
                                                                         forIndexPath:indexPath];
  OBRecipeStatistic cellType = (OBRecipeStatistic) indexPath.row;
  OBTextStatisticsCollectionViewCell *statsCell = (OBTextStatisticsCollectionViewCell *) cell;
  NSString *value = nil;
  NSString *description = nil;

  OBIbuFormula ibuFormula = [self.settings.ibuFormula integerValue];

  switch (cellType) {
    case OBOriginalGravity:
      value = [NSString stringWithFormat:@"%.3f", [self.recipe originalGravity]];
      description = @"Original gravity";
      break;
    case OBFinalGravity:
      value = [NSString stringWithFormat:@"%.3f", [self.recipe finalGravity]];
      description = @"Final gravity";
      break;
    case OBAbv:
      value = [NSString stringWithFormat:@"%.1f%%", [self.recipe alcoholByVolume]];
      description = @"ABV";
      break;
    case OBIbu:
      value = [NSString stringWithFormat:@"%d", (int) roundf([self.recipe IBUs:ibuFormula])];
      description = @"IBU";
      break;
    case OBBuToGuRatio:
      value = [NSString stringWithFormat:@"%.2f", [self.recipe bitternessToGravityRatio:ibuFormula]];
      description = @"BU:GU";
      break;
    default:
      CRITTERCISM_LOG_ERROR([NSError errorWithDomain:@"OBRecipeViewController"
                                                code:1000
                                            userInfo:@{@"cellType" : @(cellType)}]);
  }

  statsCell.statisticLabel.text = value;
  statsCell.descriptionLabel.text = description;

  return statsCell;
}

#pragma mark UICollectionViewDelegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return CGSizeMake(self.view.frame.size.width / 3.0, collectionView.frame.size.height / 2.0);
}

// Nothing happens when interacting with the statistics in the collection view,
// however, it would be useful to know if users think something *should* happen.
// This could indicate a confusing UI, or it may indicate that it's a goog place to
// add a tool tip or perhaps a way to customize the statistics.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  [self dismissKeyboard];

  if (!self.hasTriedTapping) {
    id cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSString *gaCellDescription = @"unknown";

    if ([cell respondsToSelector:@selector(descriptionLabel)]) {
      gaCellDescription = [[cell descriptionLabel] text];
    } else {
      CRITTERCISM_LOG_ERROR([NSError
                             errorWithDomain:@"OBRecipeViewController"
                             code:1003
                             userInfo:(@{ @"cellClass" : NSStringFromClass([cell class])})]);
    }

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                          action:@"Stats tapped"
                                                           label:gaCellDescription
                                                           value:nil] build]];

    self.hasTriedTapping = YES;
  }
}

@end
