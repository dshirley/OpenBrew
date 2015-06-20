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

@property (nonatomic, weak) IBOutlet UILabel *originalGravityLabel;
@property (nonatomic, weak) IBOutlet UILabel *finalGravityLabel;
@property (nonatomic, weak) IBOutlet UILabel *abvLabel;
@property (nonatomic, weak) IBOutlet UILabel *srmLabel;
@property (weak, nonatomic) IBOutlet UIView *colorSample;
@property (nonatomic, weak) IBOutlet UILabel *ibuLabel;
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

  if (!self.isMovingToParentViewController) {
    // A sub-view controller is being popped
    [self reloadData];
    [self.recipe.managedObjectContext save:nil];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  id<OBBrewController> brewController = segue.destinationViewController;
  [brewController setRecipe:self.recipe];
}

- (void)reloadData {
  self.abvLabel.text = [NSString stringWithFormat:@"%.1f%%", [self.recipe alcoholByVolume]];
  self.srmLabel.text = [NSString stringWithFormat:@"%d", (int)[self.recipe colorInSRM]];
  self.finalGravityLabel.text = [NSString stringWithFormat:@"%.3f", [self.recipe finalGravity]];
  self.ibuLabel.text = [NSString stringWithFormat:@"%d", (int) roundf([self.recipe IBUs])];
  self.originalGravityLabel.text = [NSString stringWithFormat:@"%.3f", [self.recipe originalGravity]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell"];
  OBRecipeOverviewCellType cellType = (OBRecipeOverviewCellType) indexPath.row;

  switch (cellType) {
    case OBBatchSizeCell:
      cell.textLabel.text = @"Batch size";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%d gal", [self.recipe.desiredBeerVolumeInGallons intValue]];
      break;
    case OBMaltsCell:
      cell.textLabel.text = @"Malts";
      break;
    case OBHopsCell:
      cell.textLabel.text = @"Hops";
      break;
    case OBYeastCell:
      cell.textLabel.text = @"Yeast";
      cell.detailTextLabel.text = self.recipe.yeast.yeast.name;
      break;
    default:
      NSAssert(YES, @"Invalid row: %d", indexPath.row);
  }

  return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  OBRecipeOverviewCellType cellType = (OBRecipeOverviewCellType) indexPath.row;

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
      // TODO: add yeast view controller
      break;
    default:
      NSAssert(YES, @"Invalid row when cell was selected: %d", indexPath.row);
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
      description = @"% ABV";
      break;
    case OBColor:
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
      NSAssert(YES, @"Bad index: %d", cellType);
  }

  statsCell.statisticLabel.text = value;
  statsCell.descriptionLabel.text = description;

  // Make the cell 1/3 the width of the collection view
//  CGRect frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y,
//                            cell.frame.size.width, collectionView.frame.size.width / 3);

//  statsCell.frame = frame;

  return statsCell;
}

#pragma mark UICollectionViewDelegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return CGSizeMake(self.view.frame.size.width / 3.0, collectionView.frame.size.height / 2.0);
}

@end
