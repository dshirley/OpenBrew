//
//  OBBatchSizeViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/20/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBBatchSizeViewController.h"
#import "OBRecipe.h"
#import "OBIngredientGauge.h"
#import "OBBatchSizeTableViewDelegate.h"
#import "OBKvoUtils.h"
#import <math.h>

#define MAX_GALLONS 20
#define NUM_FRACTIONAL_GALLONS_PER_GALLON 4
#define NUM_ROWS_IN_PICKER (MAX_GALLONS * NUM_FRACTIONAL_GALLONS_PER_GALLON)

@interface OBBatchSizeViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, strong) OBBatchSizeTableViewDelegate *tableViewDelegate;
@end

@implementation OBBatchSizeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)loadView {
  [super loadView];

  self.tableViewDelegate = [[OBBatchSizeTableViewDelegate alloc]
                            initWithRecipe:self.recipe
                            andTableView:self.tableView];

  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  // TODO: Do we need a display settings view for this controller?
  // Eg. [self addMaltDisplaySettingsView];

  [self reload];
}

- (void)reload {
  [self.tableView reloadData];
  [self refreshGauge];
}

- (void)refreshGauge
{
  self.gauge.valueLabel.text = [NSString stringWithFormat:@"%.2f", self.recipe.wortVolumeAfterBoilInGallons];
  self.gauge.descriptionLabel.text = @"Wort Volume";
}

#pragma mark KVO Setup

- (void)setRecipe:(OBRecipe *)recipe
{
  [_recipe removeObserver:self forKeyPath:KVO_KEY(wortVolumeAfterBoilInGallons)];
  _recipe = recipe;
  [_recipe addObserver:self forKeyPath:KVO_KEY(wortVolumeAfterBoilInGallons) options:0 context:nil];
}

- (void)dealloc
{
  self.recipe = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:KVO_KEY(wortVolumeAfterBoilInGallons)]) {
    [self refreshGauge];
  }
}

@end
