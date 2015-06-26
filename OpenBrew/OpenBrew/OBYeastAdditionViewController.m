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

// Google Analytics constants
static NSString* const OBGAScreenName = @"Yeast Addition Screen";

typedef NS_ENUM(NSInteger, OBYeastGaugeMetric) {
  OBYeastGaugeMetricFinalGravity,
  OBYeastGaugeMetricABV
};

@interface OBYeastAdditionViewController ()
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) OBYeastGaugeMetric gaugeMetric;

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
