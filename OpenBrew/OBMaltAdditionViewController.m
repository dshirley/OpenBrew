//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionViewController.h"
#import "OBMaltFinderViewController.h"
#import "OBSettings.h"
#import "OBRecipe.h"
#import "OBMalt.h"
#import "OBMaltAddition.h"
#import "OBMaltAdditionTableViewDelegate.h"
#import "OBKvoUtils.h"
#import "OBIngredientTableViewDataSource.h"
#import "OBSrmColorTable.h"
#import "OBMaltAdditionSettingsViewController.h"
#import "OBMaltDisplayMetricSegmentedControlDelegate.h"
#import "OBNumericGaugeViewController.h"
#import "OBColorGaugeViewController.h"
#import "OBPopupDrawerViewController.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Malt Addition Screen";

@interface OBMaltAdditionViewController()
@property (nonatomic) OBMaltDisplayMetricSegmentedControlDelegate *ingredientMetricSegmentedControlDelegate;
@property (nonatomic) OBPopupDrawerViewController *drawerViewController;
@end

@implementation OBMaltAdditionViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSAssert(self.settings, @"Settings were nil");

  self.placeholderView.messageLabel.text = @"No Malts";
  self.placeholderView.instructionsLabel.text = @"Tap the '+' button to add malts.";

  [self initializeGaugePageViewController];

  self.tableViewDelegate = [[OBMaltAdditionTableViewDelegate alloc] initWithRecipe:self.recipe
                                                                      andTableView:self.tableView
                                                                     andGACategory:OBGAScreenName];

  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  self.tableViewDelegate.maltAdditionMetricToDisplay = (OBMaltAdditionMetric) [self.settings.maltAdditionDisplayMetric integerValue];

  UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
  [button addTarget:self action:@selector(showSettingsView:) forControlEvents:UIControlEventTouchUpInside];
  [self.infoButton setCustomView:button];

  self.ingredientMetricSegmentedControlDelegate = [[OBMaltDisplayMetricSegmentedControlDelegate alloc] initWithSettings:self.settings];
  self.ingredientMetricSegmentedControl.gaCategory = OBGAScreenName;
  self.ingredientMetricSegmentedControl.delegate = self.ingredientMetricSegmentedControlDelegate;
}

- (void)initializeGaugePageViewController
{
  OBNumericGaugeViewController *ogGauge = [[OBNumericGaugeViewController alloc] initWithTarget:self.recipe
                                                                                  keyToDisplay:KVO_KEY(originalGravity)
                                                                                   valueFormat:@"%.3f"
                                                                               descriptionText:@"Original gravity"];

  OBColorGaugeViewController *colorGauge = [[OBColorGaugeViewController alloc] initWithTarget:self.recipe
                                                                                 keyToDisplay:KVO_KEY(colorInSRM)];

  UIPageViewController *pageViewController = (id)self.childViewControllers[0];
  self.pageViewControllerDataSource =
    [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:@[ ogGauge, colorGauge ]];

  pageViewController.dataSource = self.pageViewControllerDataSource;
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
  return (self.recipe.maltAdditions.count == 0);
}

// Changes the look and feel to have placeholder text that makes it clear
// there are no recipes available.  Also remove the unnecessary "edit" button
// to eliminate confusion.
- (void)switchToEmptyTableViewMode
{
  self.placeholderView.hidden = NO;
  self.tableView.hidden = YES;
}

- (void)switchToNonEmptyTableViewMode
{
  self.placeholderView.hidden = YES;
  self.tableView.hidden = NO;
}

#pragma mark Display Settings View Logic

- (IBAction)showSettingsView:(UIBarButtonItem *)sender
{
  if (!self.drawerViewController) {
    OBMaltAdditionSettingsViewController *settingsVc = [[OBMaltAdditionSettingsViewController alloc] initWithRecipe:self.recipe
                                                                                                           settings:self.settings];

    self.drawerViewController = [[OBPopupDrawerViewController alloc] initWithViewController:settingsVc];

    [self addChildViewController:self.drawerViewController];

    self.drawerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    [self.view addSubview:self.drawerViewController.view];
    [self.drawerViewController didMoveToParentViewController:self];
  }

  [self.drawerViewController showAnimate];
}

- (void)setRecipe:(OBRecipe *)recipe
{
  [_recipe removeObserver:self forKeyPath:KVO_KEY(originalGravity)];
  [_recipe removeObserver:self forKeyPath:KVO_KEY(maltAdditions)];

  _recipe = recipe;

  [_recipe addObserver:self forKeyPath:KVO_KEY(originalGravity) options:0 context:nil];
  [_recipe addObserver:self forKeyPath:KVO_KEY(maltAdditions) options:0 context:nil];
}

- (void)setSettings:(OBSettings *)settings
{
  [_settings removeObserver:self forKeyPath:KVO_KEY(maltAdditionDisplayMetric)];

  _settings = settings;

  [_settings addObserver:self forKeyPath:KVO_KEY(maltAdditionDisplayMetric) options:0 context:nil];
}

- (void)dealloc
{
  self.recipe = nil;
  self.settings = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  NSKeyValueChange changeType = [change[NSKeyValueChangeKindKey] integerValue];

  if ([keyPath isEqualToString:KVO_KEY(originalGravity)])
  {
    if (NSKeyValueChangeSetting == changeType) {
      // If the table is reloaded during a delete, a crash results.
      [self.tableView reloadData];
    }
  }
  else if ([keyPath isEqualToString:KVO_KEY(maltAdditionDisplayMetric)])
  {
    self.tableViewDelegate.maltAdditionMetricToDisplay = [self.settings.maltAdditionDisplayMetric integerValue];
  }
  else if ([keyPath isEqualToString:KVO_KEY(maltAdditions)])
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
  if ([[segue identifier] isEqualToString:@"addIngredient"]) {
    OBMaltFinderViewController *next = [segue destinationViewController];
    next.recipe = self.recipe;
  } else if ([[segue identifier] isEqualToString:@"maltAdditionSettings"]) {
    OBMaltAdditionSettingsViewController *next = [segue destinationViewController];
    next.settings = self.settings;
    next.recipe = self.recipe;
  }
}

#pragma mark - UnwindSegues

- (IBAction)ingredientSelected:(UIStoryboardSegue *)unwindSegue { }

- (IBAction)dismissSettingsView:(UIStoryboardSegue *)unwindSegue { }

@end
