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
#import "OBRecipe.h"
#import "OBHops.h"
#import "OBHopAddition.h"
#import "OBHopAdditionTableViewDelegate.h"
#import "OBPickerDelegate.h"
#import <math.h>
#import "OBKvoUtils.h"
#import "OBPopupView.h"
#import "OBIngredientTableViewDataSource.h"
#import "OBTableViewPlaceholderLabel.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Hop Addition Screen";
static NSString* const OBGASettingsAction = @"Settings change";

static NSString* const OBGaugeDisplaySegmentKey = @"Hop Gauge Selected Segment";
static NSString* const OBIngredientDisplaySegmentKey = @"Hop Ingredient Selected Segment";

// What hop related metric the gauge should display.  These values should
// correspond to the indices of the segements in OBHopAdditionDisplaySettings.xib
typedef NS_ENUM(NSInteger, OBHopGaugeMetric) {
  OBHopGaugeMetricIBU,
  OBHopGaugeMetricBitteringToGravityRatio
};

@interface OBHopAdditionViewController ()

// Elements from OBHopAdditionDisplaySettings.xib
@property (nonatomic, strong) OBPopupView *popupView;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) OBTableViewPlaceholderLabel *placeholderText;
@property (nonatomic, assign) OBHopGaugeMetric gaugeMetric;
@property (nonatomic, strong) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, strong) OBHopAdditionTableViewDelegate *tableViewDelegate;

@property (weak, nonatomic) IBOutlet UISegmentedControl *gaugeDisplaySettingSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ingredientDisplaySettingSegmentedControl;

@end

@implementation OBHopAdditionViewController

- (void)loadView {
  [super loadView];

  self.screenName = OBGAScreenName;

  self.tableViewDelegate = [[OBHopAdditionTableViewDelegate alloc] initWithRecipe:self.recipe
                                                                     andTableView:self.tableView
                                                                    andGACategory:OBGAScreenName];

  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  NSInteger index = [[[NSUserDefaults standardUserDefaults] valueForKey:OBGaugeDisplaySegmentKey] integerValue];
  self.gaugeMetric = (OBHopGaugeMetric)index;

  index = [[[NSUserDefaults standardUserDefaults] valueForKey:OBIngredientDisplaySegmentKey] integerValue];
  self.tableViewDelegate.hopAdditionMetricToDisplay = (OBHopAdditionMetric)index;

  [self addHopDisplaySettingsView];

  [self reload];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

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
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)switchToNonEmptyTableViewMode
{
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.tableView.tableFooterView = nil;
}

#pragma mark Display Settings View Logic

// Create the settings view and place it below the visible screen.  This view
// will pop up/down to allow users to display different hop metrics
- (void)addHopDisplaySettingsView
{
  UIView *subview =  [[[NSBundle mainBundle] loadNibNamed:@"OBHopAdditionDisplaySettings"
                                                    owner:self
                                                  options:nil] objectAtIndex:0];

  _popupView = [[OBPopupView alloc] initWithFrame:self.view.frame
                                   andContentView:subview
                                andNavigationItem:self.navigationItem];

  NSInteger index = [[[NSUserDefaults standardUserDefaults] valueForKey:OBGaugeDisplaySegmentKey] integerValue];
  self.gaugeDisplaySettingSegmentedControl.selectedSegmentIndex = index;

  index = [[[NSUserDefaults standardUserDefaults] valueForKey:OBIngredientDisplaySegmentKey] integerValue];
  self.ingredientDisplaySettingSegmentedControl.selectedSegmentIndex = index;

  [self.view addSubview:_popupView];
}

- (IBAction)showSettingsView:(UIBarButtonItem *)sender
{
  [self.popupView popupContent];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
  [super setEditing:editing animated:animated];

  // Get rid of the picker.  It'll get in the way and we don't want users to
  // be able to move it anyways.
  [self.tableView beginUpdates];
  [self.tableViewDelegate closeDrawerForTableView:self.tableView];
  [self.tableView endUpdates];

  [self.tableView setEditing:editing animated:animated];
}

- (void)reload {
  [self.tableView reloadData];
  [self refreshGauge];
}

- (void)refreshGauge
{
  if (self.gaugeMetric == OBHopGaugeMetricIBU) {
    float ibu = [self.recipe IBUs];
    _gauge.valueLabel.text = [NSString stringWithFormat:@"%d", (int) round(ibu)];
    _gauge.descriptionLabel.text = @"IBUs";
  } else if (self.gaugeMetric == OBHopGaugeMetricBitteringToGravityRatio) {
    float buToGuRatio = [self.recipe bitternessToGravityRatio];
    _gauge.valueLabel.text = [NSString stringWithFormat:@"%.2f", buToGuRatio];
    _gauge.descriptionLabel.text = @"Bitterness to Gravity Ratio";
  } else {
    [NSException raise:@"Bad OBHopGaugeMetric" format:@"Metric: %d", (int) self.gaugeMetric];
  }
}

- (void)setRecipe:(OBRecipe *)recipe
{
  [_recipe removeObserver:self forKeyPath:KVO_KEY(IBUs)];

  _recipe = recipe;

  [_recipe addObserver:self forKeyPath:KVO_KEY(IBUs) options:0 context:nil];
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
  if ([keyPath isEqualToString:KVO_KEY(IBUs)]) {
    [self refreshGauge];
  }

  if ([self tableViewIsEmpty]) {
    [self switchToEmptyTableViewMode];
  } else {
    [self switchToNonEmptyTableViewMode];
  }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"addHops"]) {
    OBHopFinderViewController *next = [segue destinationViewController];

    NSManagedObjectContext *ctx = self.recipe.managedObjectContext;

    next.tableViewDataSource = [[OBIngredientTableViewDataSource alloc]
                                initIngredientEntityName:@"Hops"
                                andManagedObjectContext:ctx];
  }
}

- (IBAction)ingredientSelected:(UIStoryboardSegue *)unwindSegue
{
  if ([[unwindSegue identifier] isEqualToString:@"IngredientSelected"]) {
    OBHopFinderViewController *finderView = [unwindSegue sourceViewController];
    OBHops *hopVariety = [finderView selectedIngredient];
    OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:hopVariety
                                                                 andRecipe:self.recipe];

    NSUInteger numberOfHops = [[self.recipe hopAdditions] count];

    hopAddition.displayOrder = [NSNumber numberWithUnsignedInteger:numberOfHops];

    [self.recipe addHopAdditionsObject:hopAddition];

    [self.recipe.managedObjectContext save:nil];
    [self reload];
  }
}

#pragma mark - HopAdditionDisplaySettings

// Linked to OBHopAdditionDisplaySettings.xib.  This method gets called when a
// UISegment is selected. This method changes the value that is displayed for
// the gauge.
- (IBAction)gaugeDisplaySettingsChanged:(UISegmentedControl *)sender
{
  OBHopGaugeMetric metric = (OBHopGaugeMetric) sender.selectedSegmentIndex;
  NSString *gaSettingName = @"n/a hop gauge metric";

  switch (metric) {
    case OBHopGaugeMetricIBU:
      gaSettingName = @"Show beer IBU";
      break;
    case OBHopGaugeMetricBitteringToGravityRatio:
      gaSettingName = @"Show beer bu:gu";
      break;
    default:
      NSAssert(YES, @"Invalid hop addition metric: %@", @(metric));
  }

  // Persist the selected segment so that it will appear the next time this view is loaded
  [[NSUserDefaults standardUserDefaults] setObject:@(metric) forKey:OBGaugeDisplaySegmentKey];

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                        action:OBGASettingsAction
                                                         label:gaSettingName
                                                         value:nil] build]];

  self.gaugeMetric = metric;

  [self refreshGauge];
}

// Linked to OBHopAdditionDisplaySettings.xib.  This method gets called when a
// UISegment is selected that changes the information displayed for each malt
// line item.
- (IBAction)ingredientDisplaySettingsChanged:(UISegmentedControl *)sender
{
  OBHopAdditionMetric metric = sender.selectedSegmentIndex;
  NSString *gaSettingName = @"n/a hop addition metric";

  switch (metric) {
    case OBHopAdditionDisplayWeight:
      gaSettingName = @"Hop weight";
      break;
    case OBHopAdditionDisplayIBU:
      gaSettingName = @"Hop ibu";
      break;
    case OBHopAdditionDisplayIBUPercent:
      gaSettingName = @"Hop ibu %";
      break;
    default:
      NSAssert(YES, @"Invalid hop addition metric: %@", @(metric));
  }

  // Persist the selected segment so that it will appear the next time this view is loaded
  [[NSUserDefaults standardUserDefaults] setObject:@(metric) forKey:OBIngredientDisplaySegmentKey];

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                        action:OBGASettingsAction
                                                         label:gaSettingName
                                                         value:nil] build]];

  // Note that the segment indices must align with the metric enum
  self.tableViewDelegate.hopAdditionMetricToDisplay = metric;
}

@end
