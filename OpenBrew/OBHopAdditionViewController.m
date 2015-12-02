//
//  OBHopAdditionViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopAdditionViewController.h"
#import "OBHopFinderViewController.h"
#import "OBSettings.h"
#import "OBRecipe.h"
#import "OBHops.h"
#import "OBHopAddition.h"
#import "OBHopAdditionTableViewDelegate.h"
#import <math.h>
#import "OBKvoUtils.h"
#import "OBIngredientTableViewDataSource.h"
#import "OBHopAdditionSettingsViewController.h"
#import "OBHopDisplayMetricSegmentedControlDelegate.h"
#import "OBNumericGaugeViewController.h"

#import "OBPopupDrawerViewController.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Hop Addition Screen";

@interface OBHopAdditionViewController()
@property (nonatomic) OBHopDisplayMetricSegmentedControlDelegate *ingredientDisplaySettingControllerDelegate;
@property (nonatomic) OBNumericGaugeViewController *ibuGauge;
@property (nonatomic) OBPopupDrawerViewController *drawerViewController;
@end

@implementation OBHopAdditionViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSAssert(self.settings, @"Settings were nil");

  self.placeholderView.messageLabel.text = @"No Hops";
  self.placeholderView.instructionsLabel.text = @"Tap the '+' button to add hops.";

  [self initializeGaugePageViewController];

  self.tableViewDelegate = [[OBHopAdditionTableViewDelegate alloc] initWithRecipe:self.recipe
                                                                     andTableView:self.tableView
                                                                    andGACategory:OBGAScreenName];

  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  self.tableViewDelegate.hopAdditionMetricToDisplay = (OBHopAdditionMetric)[self.settings.hopAdditionDisplayMetric integerValue];

  UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
  [button addTarget:self action:@selector(showSettingsView:) forControlEvents:UIControlEventTouchUpInside];
  [self.infoButton setCustomView:button];

  self.ingredientDisplaySettingControllerDelegate = [[OBHopDisplayMetricSegmentedControlDelegate alloc] initWithSettings:self.settings];
  self.ingredientMetricSegmentedControl.gaCategory = OBGAScreenName;
  self.ingredientMetricSegmentedControl.delegate = self.ingredientDisplaySettingControllerDelegate;
}

- (void)initializeGaugePageViewController
{
  UIPageViewController *pageViewController = (id)self.childViewControllers[0];

  self.ibuGauge = [[OBNumericGaugeViewController alloc] initWithTarget:self.recipe
                                                          keyToDisplay:KVO_KEY(IBUs)
                                                           valueFormat:@"%.0f"
                                                       descriptionText:@"IBUs"];

  OBNumericGaugeViewController *buToGuGauge = [[OBNumericGaugeViewController alloc] initWithTarget:self.recipe
                                                                                      keyToDisplay:KVO_KEY(bitternessToGravityRatio)
                                                                                       valueFormat:@"%.2f"
                                                                                   descriptionText:@"BU:GU"];
  self.pageViewControllerDataSource =
    [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:@[ self.ibuGauge, buToGuGauge ]];

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
  return (self.recipe.hopAdditions.count == 0);
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
    OBHopAdditionSettingsViewController *settingsVc = [[OBHopAdditionSettingsViewController alloc] initWithSettings:self.settings];

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
  [_recipe removeObserver:self forKeyPath:KVO_KEY(IBUs)];
  [_recipe removeObserver:self forKeyPath:KVO_KEY(hopAdditions)];

  _recipe = recipe;

  [_recipe addObserver:self forKeyPath:KVO_KEY(IBUs) options:0 context:nil];
  [_recipe addObserver:self forKeyPath:KVO_KEY(hopAdditions) options:0 context:nil];
}

- (void)setSettings:(OBSettings *)settings
{
  [_settings removeObserver:self forKeyPath:KVO_KEY(hopAdditionDisplayMetric)];
  [_settings removeObserver:self forKeyPath:KVO_KEY(hopQuantityUnits)];
  [_settings removeObserver:self forKeyPath:KVO_KEY(ibuFormula)];

  _settings = settings;

  [_settings addObserver:self forKeyPath:KVO_KEY(hopAdditionDisplayMetric) options:0 context:nil];
  [_settings addObserver:self forKeyPath:KVO_KEY(hopQuantityUnits) options:0 context:nil];
  [_settings addObserver:self forKeyPath:KVO_KEY(ibuFormula) options:0 context:nil];
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

  if ([keyPath isEqualToString:KVO_KEY(IBUs)])
  {
    if (NSKeyValueChangeSetting == changeType) {
      // If the table is reloaded during a delete, a crash results.
      [self.tableView reloadData];
    }
  }
  else if ([keyPath isEqualToString:KVO_KEY(ibuFormula)])
  {
    // This kind of sucks. This is the only place where the gauge doesn't update itself
    // However, it seems more complicated making OBRecipe observe OBSettings just so that it
    // can update observers of "IBUs"... I can't think of a good answer here.
    [self.ibuGauge refresh:YES];
  }
  else if ([keyPath isEqualToString:KVO_KEY(hopAdditionDisplayMetric)])
  {
    self.tableViewDelegate.hopAdditionMetricToDisplay = [self.settings.hopAdditionDisplayMetric integerValue];
  }
  else if ([keyPath isEqualToString:KVO_KEY(hopQuantityUnits)])
  {
    self.tableViewDelegate.hopQuantityUnits = [self.settings.hopQuantityUnits integerValue];
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
    next.settings = self.settings;
  }
}

#pragma mark - UnwindSegues

- (IBAction)ingredientSelected:(UIStoryboardSegue *)unwindSegue { }

- (IBAction)dismissSettingsView:(UIStoryboardSegue *)unwindSegue { }

@end
