//
//  OBHopAdditionViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopAdditionViewController.h"
#import "OBIngredientGauge.h"
#import "OBHopFinderViewController.h"
#import "OBBrewery.h"
#import "OBRecipe.h"
#import "OBHops.h"
#import "OBHopAddition.h"
#import "OBHopAdditionTableViewDelegate.h"
#import <math.h>
#import "OBKvoUtils.h"
#import "OBIngredientTableViewDataSource.h"
#import "OBTableViewPlaceholderLabel.h"
#import "OBHopAdditionSettingsViewController.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Hop Addition Screen";

@implementation OBHopAdditionViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.brewery = [OBBrewery breweryFromContext:self.recipe.managedObjectContext];

  self.tableViewDelegate = [[OBHopAdditionTableViewDelegate alloc] initWithRecipe:self.recipe
                                                                     andTableView:self.tableView
                                                                    andGACategory:OBGAScreenName];

  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  self.gauge.recipe = self.recipe;
  self.gauge.metricToDisplay = (OBGaugeMetric) [self.brewery.hopGaugeDisplayMetric integerValue];
  self.tableViewDelegate.hopAdditionMetricToDisplay = (OBHopAdditionMetric)[self.brewery.hopAdditionDisplayMetric integerValue];

  UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
  [button addTarget:self action:@selector(showSettingsView:) forControlEvents:UIControlEventTouchUpInside];
  [self.infoButton setCustomView:button];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.screenName = OBGAScreenName;

  if ([self tableViewIsEmpty]) {
    [self switchToEmptyTableViewMode];
  } else {
    [self switchToNonEmptyTableViewMode];
  }
}

// This method is here to prevent a crash.
// For a full description read either of the two following:
// https://github.com/dshirley/OpenBrew/issues/14
// http://stackoverflow.com/questions/19230446/tableviewcaneditrowatindexpath-crash-when-popping-viewcontroller
// This works around an apple bug that causes the app to crash if the swipe to
// delete button is showing when the view controller is popped.
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.tableView setEditing:NO];
}

- (BOOL)tableViewIsEmpty
{
  return (self.recipe.hopAdditions.count == 0);
}

// Changes the look and feel to have placeholder text that makes it clear
// there are no recipes available.  Also remove the unnecessary "edit" button
// to eliminate confusion.
- (void)switchToEmptyTableViewMode
{
  if (!self.placeholderText) {
    self.placeholderText = [[OBTableViewPlaceholderLabel alloc]
                            initWithFrame:self.tableView.frame
                            andText:@"No Hops"];
  }

  self.tableView.tableFooterView = self.placeholderText;
}

- (void)switchToNonEmptyTableViewMode
{
  self.tableView.tableFooterView = nil;
}

#pragma mark Display Settings View Logic

- (IBAction)showSettingsView:(UIBarButtonItem *)sender
{
  [self performSegueWithIdentifier:@"hopAdditionSettings" sender:self];
}

- (void)setRecipe:(OBRecipe *)recipe
{
  [_recipe removeObserver:self forKeyPath:KVO_KEY(IBUs)];
  [_recipe removeObserver:self forKeyPath:KVO_KEY(hopAdditions)];

  _recipe = recipe;

  [_recipe addObserver:self forKeyPath:KVO_KEY(IBUs) options:0 context:nil];
  [_recipe addObserver:self forKeyPath:KVO_KEY(hopAdditions) options:0 context:nil];
}

- (void)setBrewery:(OBBrewery *)brewery
{
  [_brewery removeObserver:self forKeyPath:KVO_KEY(hopAdditionDisplayMetric)];
  [_brewery removeObserver:self forKeyPath:KVO_KEY(hopGaugeDisplayMetric)];

  _brewery = brewery;

  [_brewery addObserver:self forKeyPath:KVO_KEY(hopAdditionDisplayMetric) options:0 context:nil];
  [_brewery addObserver:self forKeyPath:KVO_KEY(hopGaugeDisplayMetric) options:0 context:nil];
}

- (void)dealloc
{
  self.recipe = nil;
  self.brewery = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  NSKeyValueChange changeType = [change[NSKeyValueChangeKindKey] integerValue];

  if ([keyPath isEqualToString:KVO_KEY(IBUs)]) 
  {
    [self.gauge refresh];

    if (NSKeyValueChangeSetting == changeType) {
      // If the table is reloaded during a delete, a crash results.
      [self.tableView reloadData];
    }
  }
  else if ([keyPath isEqualToString:KVO_KEY(hopAdditionDisplayMetric)])
  {
    self.tableViewDelegate.hopAdditionMetricToDisplay = [self.brewery.hopAdditionDisplayMetric integerValue];
  }
  else if ([keyPath isEqualToString:KVO_KEY(hopGaugeDisplayMetric)])
  {
    self.gauge.metricToDisplay = [self.brewery.hopGaugeDisplayMetric integerValue];
  }
  else if ([keyPath isEqualToString:KVO_KEY(hopAdditions)])
  {
    if (NSKeyValueChangeInsertion == changeType) {
      [self.tableView reloadData];
      [self switchToNonEmptyTableViewMode];
    } else if ((NSKeyValueChangeRemoval == changeType) && [self tableViewIsEmpty]) {
      [self switchToEmptyTableViewMode];
    }
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"addHops"]) {
    OBHopFinderViewController *next = [segue destinationViewController];
    next.recipe = self.recipe;
  } else if ([[segue identifier] isEqualToString:@"hopAdditionSettings"]) {
    OBHopAdditionSettingsViewController *next = [segue destinationViewController];
    next.brewery = self.brewery;
  }
}

#pragma mark - UnwindSegues

- (IBAction)ingredientSelected:(UIStoryboardSegue *)unwindSegue { }

- (IBAction)dismissSettingsView:(UIStoryboardSegue *)unwindSegue { }

@end
