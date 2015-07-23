//
//  OBYeastAdditionViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 6/25/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBYeastAdditionViewController.h"
#import "OBIngredientTableViewDataSource.h"
#import "OBIngredientGauge.h"
#import "OBRecipe.h"
#import "OBYeast.h"
#import "OBYeastAddition.h"
#import "Crittercism+NSErrorLogging.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "OBYeastTableViewCell.h"


// Google Analytics constants
static NSString* const OBGAScreenName = @"Yeast Addition Screen";

// Indices of the UISegmentControl of the OBMaltFinderViewController in storyboard
#define WHITE_LABS_SEGMENT_INDEX 0
#define WYEAST_SEGMENT_INDEX 1

NSString * const filterLabels[] = {
  [WHITE_LABS_SEGMENT_INDEX] = @"White Labs",
  [WYEAST_SEGMENT_INDEX] = @"Wyeast"
};

OBYeastManufacturer const manufacturerToSegmentMapping[] = {
  [WHITE_LABS_SEGMENT_INDEX] = OBYeastManufacturerWhiteLabs,
  [WYEAST_SEGMENT_INDEX] = OBYeastManufacturerWyeast
};

#define NUMBER_OF_SEGMENTS (sizeof(filterLabels) / sizeof(NSString *))

typedef NS_ENUM(NSInteger, OBYeastGaugeMetric) {
  OBYeastGaugeMetricFinalGravity,
  OBYeastGaugeMetricABV
};

@interface OBYeastAdditionViewController ()

@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) OBYeastGaugeMetric gaugeMetric;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSArray *ingredientData;
@property (nonatomic, assign) OBYeastManufacturer selectedManufacturer;

@end

@implementation OBYeastAdditionViewController

- (void)loadView {
  [super loadView];

  self.screenName = OBGAScreenName;

  // Setup segments in filter
  [self.segmentedControl removeAllSegments];

  for (int i = 0; i < NUMBER_OF_SEGMENTS; i++) {
    [self.segmentedControl insertSegmentWithTitle:filterLabels[i] atIndex:i animated:NO];
  }

  [self.segmentedControl setSelectedSegmentIndex:WHITE_LABS_SEGMENT_INDEX];

  self.selectedManufacturer = OBYeastManufacturerWhiteLabs;

  [self reloadTable];
  [self refreshGauge];
}

// Query the CoreData store to get all of the ingredient data
- (void)reloadTable
{
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Yeast"
                                                       inManagedObjectContext:self.recipe.managedObjectContext];

  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"identifier"
                                                                 ascending:YES];

  [request setSortDescriptors:@[sortDescriptor]];

  NSError *error = nil;
  NSArray *array = [self.recipe.managedObjectContext executeFetchRequest:request error:&error];

  if (error) {
    CRITTERCISM_LOG_ERROR(error);
    array = [NSArray array];
  }

  NSPredicate *filter = [NSPredicate predicateWithFormat:@"manufacturer == %d", self.selectedManufacturer];
  self.ingredientData = [array filteredArrayUsingPredicate:filter];

  [self.tableView reloadData];
}

- (void)refreshGauge
{
  [self.gauge hideColor];

  if (self.gaugeMetric == OBYeastGaugeMetricFinalGravity) {
    float finalGravity = [self.recipe finalGravity];
    _gauge.valueLabel.text = [NSString stringWithFormat:@"%.3f", finalGravity];
    _gauge.descriptionLabel.text = @"Final Gravity";
  } else if (self.gaugeMetric == OBYeastGaugeMetricABV) {
    _gauge.valueLabel.text = [NSString stringWithFormat:@"%.1f%%", [self.recipe alcoholByVolume]];
    _gauge.descriptionLabel.text = @"ABV";
  } else {
    [NSException raise:@"Bad OBYeastGaugeMetric" format:@"Metric: %d", (int) self.gaugeMetric];
  }
}

- (IBAction)filterValueChanged:(UISegmentedControl *)sender {
  self.selectedManufacturer = manufacturerToSegmentMapping[sender.selectedSegmentIndex];

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                        action:@"Filter"
                                                         label:filterLabels[sender.selectedSegmentIndex]
                                                         value:nil] build]];

  [self reloadTable];
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  OBYeast *yeast = self.ingredientData[indexPath.row];
  OBYeastAddition *yeastAddition = [[OBYeastAddition alloc] initWithYeast:yeast andRecipe:self.recipe];

  self.recipe.yeast = yeastAddition;

  NSError *error = nil;
  [self.recipe.managedObjectContext save:&error];
  CRITTERCISM_LOG_ERROR(error);

  [self refreshGauge];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.ingredientData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = nil;
  NSString *reuseIdentifier = nil;

  if (self.selectedManufacturer == OBYeastManufacturerWhiteLabs) {
    reuseIdentifier = @"WhiteLabsCell";
  } else if (self.selectedManufacturer == OBYeastManufacturerWyeast) {
    reuseIdentifier = @"WyeastCell";
  } else {
    [NSException raise:@"Invalid manufacturer" format:@"Manufacturer: %@", @(self.selectedManufacturer)];
  }

  cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier
                                         forIndexPath:indexPath];

  // Yeast cell... no pun intended
  OBYeastTableViewCell *yeastCell = (OBYeastTableViewCell *)cell;

  OBYeast *yeast = self.ingredientData[indexPath.row];

  yeastCell.yeastIdentifier.text = yeast.identifier;
  yeastCell.yeastName.text = yeast.name;

  return yeastCell;
}


@end
