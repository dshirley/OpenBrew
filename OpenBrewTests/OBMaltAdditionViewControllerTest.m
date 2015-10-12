//
//  OBMaltAdditionViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/1/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBMaltAdditionViewController.h"
#import "OBMaltAdditionTableViewDelegate.h"
#import "OBBaseTestCase.h"
#import <OCMock/OCMock.h>
#import "OBMaltAdditionTableViewCell.h"
#import "OBMaltAddition.h"
#import "OBMaltFinderViewController.h"
#import "OBMaltAdditionSettingsViewController.h"
#import "OBGaugePageViewController.h"
#import "OBMaltDisplayMetricSegmentedControlDelegate.h"
#import "OBKvoUtils.h"

@interface OBMaltAdditionViewControllerTest : OBBaseTestCase
@property (nonatomic) OBMaltAdditionViewController *vc;
@end

@implementation OBMaltAdditionViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"maltAdditions"];
  self.vc.settings = self.settings;
  self.vc.recipe = self.recipe;
}

- (void)tearDown {
  self.vc = nil;

  [super tearDown];
}

- (void)loadViewController
{
  (void)self.vc.view;
}

- (void)testViewDidLoad_settingsIsSet
{
  [self loadViewController];

  XCTAssertEqual(self.settings, self.vc.settings);
}

- (void)testViewDidLoad_tableViewDelegateIsSetup
{
  [self loadViewController];

  XCTAssertNotNil(self.vc.tableViewDelegate);
  XCTAssertEqual(self.vc.tableViewDelegate, self.vc.tableView.delegate);
  XCTAssertEqual(self.vc.tableViewDelegate, self.vc.tableView.dataSource);

  XCTAssertEqual(self.vc.tableViewDelegate.recipe, self.recipe);
  XCTAssertEqual(self.vc.recipe, self.recipe);
}

- (void)testViewDidLoad_gaugeIsSetup
{
  [self loadViewController];

  XCTAssertNotNil(self.vc.pageViewControllerDataSource);
  XCTAssertNotNil(self.vc.pageViewControllerDataSource.viewControllers);
  XCTAssertEqual(2, self.vc.pageViewControllerDataSource.viewControllers.count);

  XCTAssertEqual(self.recipe, [self.vc.pageViewControllerDataSource.viewControllers[0] target]);
  XCTAssertEqualObjects(KVO_KEY(originalGravity), [self.vc.pageViewControllerDataSource.viewControllers[0] key]);

  XCTAssertEqual(self.recipe, [self.vc.pageViewControllerDataSource.viewControllers[1] target]);
  XCTAssertEqualObjects(KVO_KEY(colorInSRM), [self.vc.pageViewControllerDataSource.viewControllers[1] key]);

  XCTAssertEqual(1, self.vc.childViewControllers.count);

  OBGaugePageViewController *pageViewController = (id)self.vc.childViewControllers[0];
  XCTAssertEqual(OBGaugePageViewController.class, pageViewController.class);
  XCTAssertEqual(self.vc.pageViewControllerDataSource, pageViewController.dataSource);
}

- (void)testViewDidLoad_maltAdditionMetricUsesStoredSettings
{
  self.settings.maltAdditionDisplayMetric = @(OBMaltAdditionMetricPercentOfGravity);

  [self loadViewController];
  XCTAssertEqual(OBMaltAdditionMetricPercentOfGravity, self.vc.tableViewDelegate.maltAdditionMetricToDisplay);

  self.settings.maltAdditionDisplayMetric = @(OBMaltAdditionMetricWeight);
  [self.vc viewDidLoad];
  XCTAssertEqual(OBMaltAdditionMetricWeight, self.vc.tableViewDelegate.maltAdditionMetricToDisplay);
}

- (void)testViewDidLoad_infoButtonIsSetup
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];

  [self loadViewController];

  UIButton *button = (UIButton *)self.vc.infoButton.customView;
  XCTAssertNotNil(button);
  XCTAssertEqual(UIButtonTypeInfoDark, button.buttonType);

  [[mockVc expect] performSegueWithIdentifier:@"maltAdditionSettings" sender:self.vc];

  [button sendActionsForControlEvents:UIControlEventTouchUpInside];

  [mockVc verify];
}

- (void)testViewDidLoad_tableViewHasCorrectData
{
  [self addMalt:@"Acid Malt" quantity:1.0 color:4];
  [self addMalt:@"Two-Row" quantity:10.0 color:2];

  [self loadViewController];

  XCTAssertEqual(2, [self.vc.tableView numberOfRowsInSection:0]);

  OBMaltAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Acid Malt", cell.maltVariety.text);
  XCTAssertEqualObjects(@"1lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"4 Lovibond", cell.color.text);

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"Two-Row", cell.maltVariety.text);
  XCTAssertEqualObjects(@"10lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"2 Lovibond", cell.color.text);
}

- (void)testViewDidLoad_segmentedControllerDelegateIsSet
{
  [self loadViewController];

  OBMaltDisplayMetricSegmentedControlDelegate *delegate = self.vc.ingredientMetricSegmentedControl.delegate;

  XCTAssertNotNil(delegate);
  XCTAssertEqualObjects(NSStringFromClass(OBMaltDisplayMetricSegmentedControlDelegate.class),
                        NSStringFromClass(delegate.class));

  XCTAssertEqual(self.settings, delegate.settings);
}

- (void)testViewUpdatesWhenMaltAdditionsChange
{
  OBMaltAddition *maltAddition = [self addMalt:@"Two-Row" quantity:10.0 color:2];

  [self loadViewController];

  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);

  OBMaltAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Two-Row", cell.maltVariety.text);
  XCTAssertEqualObjects(@"10lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"2 Lovibond", cell.color.text);

  maltAddition.quantityInPounds = @(5.0);

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Two-Row", cell.maltVariety.text);
  XCTAssertEqualObjects(@"5lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"2 Lovibond", cell.color.text);
}

- (void)testDeleteMaltAddition
{
  [self addMalt:@"Two-Row" quantity:10.0 color:2];
  OBMaltAddition *maltAddition2 = [self addMalt:@"Pilsner Malt" quantity:3.0 color:1];

  [self loadViewController];

  XCTAssertEqual(2, [self.vc.tableView numberOfRowsInSection:0]);

  [self.vc.tableViewDelegate tableView:self.vc.tableView
                    commitEditingStyle:UITableViewCellEditingStyleDelete
                     forRowAtIndexPath:self.r0s0];

  XCTAssertEqualObjects((@[ maltAddition2 ]), [self.recipe maltAdditionsSorted]);
  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertNil(self.vc.tableView.tableFooterView);

  OBMaltAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Pilsner Malt", cell.maltVariety.text);
  XCTAssertEqualObjects(@"3lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"1 Lovibond", cell.color.text);
}

- (void)testDeletingLastMaltAdditionShowsPlaceholderView
{
  [self addMalt:@"Pilsner Malt" quantity:3.0 color:1];

  [self loadViewController];
  [self.vc viewWillAppear:NO];

  XCTAssertNil(self.vc.tableView.tableFooterView);

  [self.vc.tableViewDelegate tableView:self.vc.tableView
                    commitEditingStyle:UITableViewCellEditingStyleDelete
                     forRowAtIndexPath:self.r0s0];

  OBPlaceholderView *placeholderView = self.vc.placeholderView;
  XCTAssertFalse(placeholderView.hidden);
  XCTAssertEqualObjects(@"No Malts", placeholderView.messageLabel.text);
}

// Malts should be added via KVO
- (void)testAddMalt
{
  [self loadViewController];
  [self.vc viewWillAppear:YES];

  XCTAssertEqual(0, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertFalse(self.vc.placeholderView.hidden);
  XCTAssertTrue(self.vc.tableView.hidden);

  [self addMalt:@"Two-Row" quantity:10.0 color:2];
  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertTrue(self.vc.placeholderView.hidden);
  XCTAssertFalse(self.vc.tableView.hidden);

  OBMaltAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Two-Row", cell.maltVariety.text);
  XCTAssertEqualObjects(@"10lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"2 Lovibond", cell.color.text);

  // Add some more malts
  [self addMalt:@"Pilsner Malt" quantity:3.0 color:1];

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Two-Row", cell.maltVariety.text);
  XCTAssertEqualObjects(@"10lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"2 Lovibond", cell.color.text);

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"Pilsner Malt", cell.maltVariety.text);
  XCTAssertEqualObjects(@"3lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"1 Lovibond", cell.color.text);
}

- (void)testMaltAdditionDisplaySettingChanged
{
  [self loadViewController];

  id mockDelegate = [OCMockObject partialMockForObject:self.vc.tableViewDelegate];
  [[mockDelegate expect] setMaltAdditionMetricToDisplay:OBMaltAdditionMetricPercentOfGravity];

  self.settings.maltAdditionDisplayMetric = @(OBMaltAdditionMetricPercentOfGravity);

  [mockDelegate verify];
}

- (void)testViewWillAppear_WhenEmpty
{
  [self loadViewController];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Malt Addition Screen", self.vc.screenName);

  XCTAssertFalse(self.vc.placeholderView.hidden);
  XCTAssertEqualObjects(@"No Malts", self.vc.placeholderView.messageLabel.text);
}

- (void)testViewWillAppear_WhenThereAreMalts
{
 [self addMalt:@"Two-Row" quantity:10.0 color:2];

  [self loadViewController];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Malt Addition Screen", self.vc.screenName);
  XCTAssertNil(self.vc.tableView.tableFooterView);
}

- (void)testPrepareForSegue_MaltFinder
{
  [self loadViewController];

  OBMaltFinderViewController *maltFinder = [[OBMaltFinderViewController alloc] init];
  maltFinder.recipe = nil;

  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"addIngredient"
                                                                    source:self.vc
                                                               destination:maltFinder];

  [self.vc prepareForSegue:segue sender:nil];

  XCTAssertNotNil(maltFinder.recipe);
  XCTAssertEqual(self.vc.recipe, maltFinder.recipe);
}

- (void)testPrepareForSegue_MaltSettings
{
  [self loadViewController];

  OBMaltAdditionSettingsViewController *settingsVc = [[OBMaltAdditionSettingsViewController alloc] init];
  settingsVc.settings = nil;

  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"maltAdditionSettings"
                                                                    source:self.vc
                                                               destination:settingsVc];

  [self.vc prepareForSegue:segue sender:nil];

  XCTAssertNotNil(settingsVc.settings);
  XCTAssertEqual(self.vc.settings, settingsVc.settings);
  XCTAssertEqual(self.vc.recipe, settingsVc.recipe);
}

- (void)testViewWillDissappear
{
  [self.vc loadView];

  self.vc.tableView.editing = YES;
  [self.vc viewWillDisappear:NO];

  XCTAssertEqual(NO, self.vc.tableView.editing);
}

@end
