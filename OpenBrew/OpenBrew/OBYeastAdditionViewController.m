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

// We have to hold a strong reference to this because the tableView doesn't
@property (strong, nonatomic) OBIngredientTableViewDataSource *dataSource;
@end

@implementation OBYeastAdditionViewController

- (void)loadView {
  [super loadView];

  self.screenName = OBGAScreenName;

  NSManagedObjectContext *ctx = self.recipe.managedObjectContext;

  self.dataSource = [[OBIngredientTableViewDataSource alloc]
                               initIngredientEntityName:@"Yeast"
                               andManagedObjectContext:ctx];

  self.tableView.dataSource = self.dataSource;

  // Setup segments in filter
  [self.segmentedControl removeAllSegments];

  for (int i = 0; i < NUMBER_OF_SEGMENTS; i++) {
    [self.segmentedControl insertSegmentWithTitle:filterLabels[i] atIndex:i animated:NO];
  }

  [self.segmentedControl setSelectedSegmentIndex:WHITE_LABS_SEGMENT_INDEX];

  [self reload];
}

- (void)reload {
  [self.tableView reloadData];
  [self refreshGauge];
}

- (void)refreshGauge
{
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
  OBYeastManufacturer manufacturer = manufacturerToSegmentMapping[sender.selectedSegmentIndex];

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                        action:@"Filter"
                                                         label:filterLabels[sender.selectedSegmentIndex]
                                                         value:nil] build]];

  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"manufacturer == %d", manufacturer];
  self.dataSource.predicate = predicate;
  [self.tableView reloadData];
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  OBYeast *yeast = [self.dataSource ingredientAtIndexPath:indexPath];
  OBYeastAddition *yeastAddition = [[OBYeastAddition alloc] initWithYeast:yeast andRecipe:self.recipe];

  self.recipe.yeast = yeastAddition;

  NSError *error = nil;
  [self.recipe.managedObjectContext save:&error];
  CRITTERCISM_LOG_ERROR(error);

  [self reload];
}


@end
