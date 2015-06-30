//
//  OBRecipeOverviewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/26/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipeOverviewController.h"
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

// Google Analytics event category
static NSString* const OBGAScreenName = @"Recipe Overview Screen";

typedef NS_ENUM(NSInteger, OBRecipeOverviewCellType) {
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

@interface OBRecipeOverviewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITextField *recipeNameTextField;
@end

@implementation OBRecipeOverviewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self reloadData];
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

  if (!self.isMovingToParentViewController) {
    // A sub-view controller is being popped
    [self reloadData];
    [self.recipe.managedObjectContext save:nil];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  id<OBBrewController> brewController = segue.destinationViewController;
  [brewController setRecipe:self.recipe];
}

- (void)reloadData {
  [self.collectionView reloadData];
  [self.tableView reloadData];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  assert(textField == self.recipeNameTextField);

  self.recipe.name = self.recipeNameTextField.text;

  NSError *error = nil;
  [self.recipe.managedObjectContext save:&error];
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
    [seenHops addObject:hopAddition.hops.name];
  }

  return seenHops.count;
}

- (NSUInteger)numberOfMaltVarieties
{
  NSMutableSet *seenMalts = [NSMutableSet set];

  for (OBMaltAddition *maltAddition in self.recipe.maltAdditions) {
    [seenMalts addObject:maltAddition.malt.name];
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
  OBRecipeOverviewCellType cellType = (OBRecipeOverviewCellType) indexPath.row;
  NSUInteger count = 0;

  switch (cellType) {
    case OBBatchSizeCell:
      cell.textLabel.text = @"Batch size";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f gallons", [self.recipe.desiredBeerVolumeInGallons floatValue]];
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
        cell.detailTextLabel.text = self.recipe.yeast.yeast.name;
      } else {
        cell.detailTextLabel.text = @"none";
      }
      break;
    default:
      NSAssert(YES, @"Invalid row: %@", @(indexPath.row));
  }

  return cell;
}

- (void)dismissKeyboard
{
  // This is pretty annoying: dismiss the keyboard if the user was editing the recipe title.
  // TODO: is there a more efficient way to do this?  Surely if there were 10 different components, this
  // code wouldn't need to be added to each of them.
  [self.view endEditing:YES];
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  OBRecipeOverviewCellType cellType = (OBRecipeOverviewCellType) indexPath.row;

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
      NSAssert(YES, @"Invalid row when cell was selected: %ld", (long)indexPath.row);
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
      value = [NSString stringWithFormat:@"%d", (int) roundf([self.recipe IBUs])];
      description = @"IBU";
      break;
    case OBBuToGuRatio:
      value = [NSString stringWithFormat:@"%.2f", [self.recipe bitternessToGravityRatio]];
      description = @"BU:GU";
      break;
    default:
      NSAssert(YES, @"Bad index: %ld", (long)cellType);
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
  static BOOL hasTriedTapping = NO;

  [self dismissKeyboard];

  if (hasTriedTapping) {
    id cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSString *gaCellDescription = @"unknown";

    NSAssert([cell respondsToSelector:@selector(descriptionLabel)], @"All cells should have a description label");
    if ([cell respondsToSelector:@selector(descriptionLabel)]) {
      gaCellDescription = [[cell descriptionLabel] text];
    }

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                          action:@"Stats tapped"
                                                           label:gaCellDescription
                                                           value:nil] build]];

    hasTriedTapping = YES;
  }
}

@end
