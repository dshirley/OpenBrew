//
//  OBYeastAdditionViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 6/25/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBYeastAdditionViewController.h"
#import "OBIngredientTableViewDataSource.h"
#import "OBRecipe.h"
#import "OBYeast.h"
#import "OBYeastAddition.h"
#import "Crittercism+NSErrorLogging.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "OBYeastTableViewCell.h"
#import "OBSettings.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Yeast Addition Screen";

@interface OBYeastAdditionViewController ()

@property (nonatomic) NSFetchedResultsController *fetchedResults;

@property (nonatomic) NSArray *segmentedControlDelegateTitles;
@property (nonatomic) NSArray *segmentedControlDelegateValues;

@end

@implementation OBYeastAdditionViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.screenName = OBGAScreenName;

  UIPageViewController *pageViewController = (id)self.childViewControllers[0];
  self.pageViewControllerDataSource =
    [[OBGaugePageViewControllerDataSource alloc] initWithRecipe:self.recipe
                                                       settings:self.settings
                                                 displayMetrics:@[ @(OBMetricAbv), @(OBMetricFinalGravity) ]];

  pageViewController.dataSource = self.pageViewControllerDataSource;

  NSAssert(self.settings, @"Settings were nil");

  self.segmentedControlDelegateTitles = @[ @"White Labs", @"Wyeast" ];
  self.segmentedControlDelegateValues = @[ @(OBYeastManufacturerWhiteLabs), @(OBYeastManufacturerWyeast)];
  self.segmentedControl.gaCategory = OBGAScreenName;
  self.segmentedControl.delegate = (id)self;

  [self reloadTableSelectedManufacturer:[self initiallySelectedManufacturer] scrollToSelectedItem:YES];
}

- (NSInteger)initiallySelectedManufacturer
{
  if (self.recipe.yeast) {
    return [self.recipe.yeast.manufacturer integerValue];
  } else {
    return [self.settings.selectedYeastManufacturer integerValue];
  }
}

// Query the CoreData store to get all of the ingredient data
- (void)reloadTableSelectedManufacturer:(OBYeastManufacturer)yeastManufacturer scrollToSelectedItem:(BOOL)shouldScroll
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];

  request.entity = [NSEntityDescription entityForName:@"Yeast" inManagedObjectContext:self.recipe.managedObjectContext];
  request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:YES]];
  request.predicate = [NSPredicate predicateWithFormat:@"manufacturer == %d", (int) yeastManufacturer];
  request.includesSubentities = NO;

  self.fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                            managedObjectContext:self.recipe.managedObjectContext sectionNameKeyPath:nil
                                                                       cacheName:@"FIXME"];

  NSError *error = nil;

  if (![self.fetchedResults performFetch:&error]) {
    CRITTERCISM_LOG_ERROR(error);
  }

  [self.tableView reloadData];

  NSIndexPath *selectedIndexPath = [self.fetchedResults indexPathForObject:[self selectedYeast]];
  if (selectedIndexPath) {
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

    if (shouldScroll) {
      [self.tableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
  }
}

- (OBYeast *)selectedYeast
{
  if (!self.recipe.yeast) {
    return nil;
  }

  NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Yeast"];
  fetchRequest.includesSubentities = NO;
  fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier == %@", self.recipe.yeast.identifier];

  NSError *error = nil;
  NSArray *selectedYeasts = [self.recipe.managedObjectContext executeFetchRequest:fetchRequest error:&error];

  if (selectedYeasts.count == 1) {
    return selectedYeasts[0];
  } else if (selectedYeasts.count > 1) {
    NSString *list = nil;
    for (OBYeast *yeast in selectedYeasts) {
      list = [NSString stringWithFormat:@"%@ %@", list, yeast.name];
    }

    CRITTERCISM_LOG_ERROR([NSError errorWithDomain:@"OBYeastAdditionViewController"
                                              code:1000
                                          userInfo:(@{ @"yeasts" : list})]);

    return selectedYeasts[0];
  }

  return nil;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  OBYeast *yeast = [self.fetchedResults objectAtIndexPath:indexPath];
  OBYeastAddition *yeastAddition = [[OBYeastAddition alloc] initWithYeast:yeast andRecipe:self.recipe];

  self.recipe.yeast = yeastAddition;

  NSError *error = nil;
  [self.recipe.managedObjectContext save:&error];
  CRITTERCISM_LOG_ERROR(error);

//  [self.gauge refresh];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[self.fetchedResults.sections objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = nil;
  NSString *reuseIdentifier = nil;

  OBYeastManufacturer selectedYeastManufacturer = [self.settings.selectedYeastManufacturer integerValue];

  if (OBYeastManufacturerWhiteLabs == selectedYeastManufacturer) {
    reuseIdentifier = @"WhiteLabsCell";
  } else if (OBYeastManufacturerWyeast == selectedYeastManufacturer) {
    reuseIdentifier = @"WyeastCell";
  } else {
    [NSException raise:@"Invalid manufacturer" format:@"Manufacturer: %@", @(selectedYeastManufacturer)];
  }

  cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                         forIndexPath:indexPath];

  // Yeast cell... no pun intended
  OBYeastTableViewCell *yeastCell = (OBYeastTableViewCell *)cell;

  OBYeast *yeast = [self.fetchedResults objectAtIndexPath:indexPath];

  yeastCell.yeastIdentifier.text = yeast.identifier;
  yeastCell.yeastName.text = yeast.name;

  return yeastCell;
}

#pragma mark OBSegmentedControlDelegate methods

- (NSArray *)segmentTitlesForSegmentedControl:(UISegmentedControl *)segmentedControl
{
  return self.segmentedControlDelegateTitles;
}

- (void)segmentedControl:(UISegmentedControl *)segmentedControl segmentSelected:(NSInteger)index
{
  NSArray *values = self.segmentedControlDelegateValues;
  self.settings.selectedYeastManufacturer = values[index];
  [self reloadTableSelectedManufacturer:[values[index] integerValue] scrollToSelectedItem:NO];
}

- (NSInteger)initiallySelectedSegmentForSegmentedControl:(UISegmentedControl *)segmentedControl
{
  OBYeastManufacturer initialManufacturer = [self initiallySelectedManufacturer];
  return [self.segmentedControlDelegateValues indexOfObject:@(initialManufacturer)];
}


@end
