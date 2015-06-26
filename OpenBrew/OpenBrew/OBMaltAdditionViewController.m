//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionViewController.h"
#import "OBIngredientGauge.h"
#import "OBMaltFinderViewController.h"
#import "OBRecipe.h"
#import "OBMalt.h"
#import "OBMaltAddition.h"
#import "OBMaltAdditionTableViewDelegate.h"
#import "OBKvoUtils.h"
#import "OBPopupView.h"
#import "OBIngredientTableViewDataSource.h"
#import "OBSrmColorTable.h"
#import "OBTableViewPlaceholderLabel.h"
#import "Crittercism+NSErrorLogging.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Malt Addition Screen";
static NSString* const OBGASettingsAction = @"Settings change";

static NSString* const OBGaugeDisplaySegmentKey = @"Malt Gauge Selected Segment";
static NSString* const OBIngredientDisplaySegmentKey = @"Malt Ingredient Selected Segment";

// What malt related metric should the gauge display.  These values should
// correspond to the indices of the MaltAdditionDisplaySettings segmentview.
typedef NS_ENUM(NSInteger, OBMaltGaugeMetric) {
  OBMaltGaugeMetricGravity,
  OBMaltGaugeMetricColor
};

@interface OBMaltAdditionViewController ()

// Elements from OBMaltAdditionDisplaySettings.xib
@property (nonatomic, strong) OBPopupView *popupView;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) OBTableViewPlaceholderLabel *placeholderText;
@property (nonatomic, assign) OBMaltGaugeMetric gaugeMetric;
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, strong) OBMaltAdditionTableViewDelegate *tableViewDelegate;

@property (weak, nonatomic) IBOutlet UISegmentedControl *gaugeDisplaySettingSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ingredientDisplaySettingSegmentedControl;

@end

@implementation OBMaltAdditionViewController

- (void)loadView {
  [super loadView];

  self.screenName = OBGAScreenName;

  self.tableViewDelegate = [[OBMaltAdditionTableViewDelegate alloc] initWithRecipe:self.recipe
                                                                      andTableView:self.tableView
                                                                     andGACategory:OBGAScreenName];

  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  NSInteger index = [[[NSUserDefaults standardUserDefaults] valueForKey:OBGaugeDisplaySegmentKey] integerValue];
  self.gaugeMetric = (OBMaltGaugeMetric)index;

  index = [[[NSUserDefaults standardUserDefaults] valueForKey:OBIngredientDisplaySegmentKey] integerValue];
  self.tableViewDelegate.maltAdditionMetricToDisplay = (OBMaltAdditionMetric)index;

  [self addMaltDisplaySettingsView];

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
  return (self.recipe.maltAdditions.count == 0);
}

// Changes the look and feel to have placeholder text that makes it clear
// there are no recipes available.  Also remove the unnecessary "edit" button
// to eliminate confusion.
- (void)switchToEmptyTableViewMode
{
  if (!self.placeholderText) {
    self.placeholderText = [[OBTableViewPlaceholderLabel alloc]
                            initWithFrame:self.tableView.frame
                            andText:@"No Malts"];
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
// will pop up/down to allow users to display different malt metrics
- (void)addMaltDisplaySettingsView
{
  UIView *subview =  [[[NSBundle mainBundle] loadNibNamed:@"OBMaltAdditionDisplaySettings"
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
  NSInteger srm = roundf([self.recipe colorInSRM]);

  if (self.gaugeMetric == OBMaltGaugeMetricGravity) {
    float gravity = [self.recipe originalGravity];
    _gauge.colorInSrm = 0;
    _gauge.valueLabel.text = [NSString stringWithFormat:@"%.3f", gravity];
    _gauge.descriptionLabel.text = @"Starting Gravity";
  } else if (self.gaugeMetric == OBMaltGaugeMetricColor) {
    _gauge.colorInSrm = srm;
    _gauge.valueLabel.text = @"";
    _gauge.descriptionLabel.text = [NSString stringWithFormat:@"%ld SRM", (long)srm];
  } else {
    [NSException raise:@"Bad OBMaltGaugeMetric" format:@"Metric: %d", (int) self.gaugeMetric];
  }
}

- (void)setRecipe:(OBRecipe *)recipe
{
  [_recipe removeObserver:self forKeyPath:KVO_KEY(originalGravity)];

  _recipe = recipe;

  [_recipe addObserver:self forKeyPath:KVO_KEY(originalGravity) options:0 context:nil];
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
  if ([keyPath isEqualToString:KVO_KEY(originalGravity)]) {
    [self refreshGauge];

    // This if statement is a bit of a hack.  It allows detecting changes to
    // the malt bill.  However, we certainly don't need to update the view when
    // the malt addition weight changes or when the color changes. This is much
    // simpler than adding a callback to the table view data source delegate.
    if ([self tableViewIsEmpty]) {
      [self switchToEmptyTableViewMode];
    } else {
      [self switchToNonEmptyTableViewMode];
    }
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"addIngredient"]) {

    OBMaltFinderViewController *next = [segue destinationViewController];

    NSManagedObjectContext *ctx = self.recipe.managedObjectContext;

    next.tableViewDataSource = [[OBIngredientTableViewDataSource alloc]
                                initIngredientEntityName:@"Malt"
                                andManagedObjectContext:ctx];
  }
}

- (IBAction)ingredientSelected:(UIStoryboardSegue *)unwindSegue
{
  if ([[unwindSegue identifier] isEqualToString:@"IngredientSelected"]) {
    OBMaltFinderViewController *finderView = [unwindSegue sourceViewController];
    OBMalt *malt = [finderView selectedIngredient];
    OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:malt
                                                              andRecipe:self.recipe];

    NSUInteger numberOfMalts = [[self.recipe maltAdditions] count];
    maltAddition.displayOrder = [NSNumber numberWithUnsignedInteger:numberOfMalts];

    [self.recipe addMaltAdditionsObject:maltAddition];

    NSError *error = nil;
    [self.recipe.managedObjectContext save:&error];
    CRITTERCISM_LOG_ERROR(error);

    [self reload];
  }
}

#pragma mark - MaltAdditionDisplaySettings

// Linked to OBMaltAdditionDisplaySettings.xib.  This method gets called when a
// UISegment is selected. This method changes the value that is displayed for
// the gauge.
- (IBAction)gaugeDisplaySettingsChanged:(UISegmentedControl *)sender
{
  OBMaltGaugeMetric metric = (OBMaltGaugeMetric) sender.selectedSegmentIndex;
  NSString *gaSettingName = @"n/a gauge action";

  switch (metric) {
    case OBMaltGaugeMetricColor:
      gaSettingName = @"Show beer color";
      break;
    case OBMaltGaugeMetricGravity:
      gaSettingName = @"Show beer gravity";
      break;
    default:
      NSAssert(YES, @"Invalid gauge metric: %@", @(metric));
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

// Linked to OBMaltAdditionDisplaySettings.xib.  This method gets called when a
// UISegment is selected that changes the information displayed for each malt
// line item.
- (IBAction)ingredientDisplaySettingsChanged:(UISegmentedControl *)sender
{
  OBMaltAdditionMetric metric = (OBMaltAdditionMetric) sender.selectedSegmentIndex;
  NSString *gaSettingName = @"n/a ingredient action";

  switch (metric) {
    case OBMaltAdditionMetricWeight:
      gaSettingName = @"Show malt weight";
      break;
    case OBMaltAdditionMetricPercentOfGravity:
      gaSettingName = @"Show % gravity";
      break;
    default:
      NSAssert(YES, @"Invalid malt addition metric: %@", @(metric));
  }

  // Persist the selected segment so that it will appear the next time this view is loaded
  [[NSUserDefaults standardUserDefaults] setObject:@(metric) forKey:OBIngredientDisplaySegmentKey];

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                        action:OBGASettingsAction
                                                         label:gaSettingName
                                                         value:nil] build]];

  // Note that the segment indices must align with the metric enum
  self.tableViewDelegate.maltAdditionMetricToDisplay = metric;
}

@end
