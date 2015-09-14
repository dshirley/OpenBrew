//
//  OBHopAdditionViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBHopAdditionViewController.h"
#import "OBHopAdditionTableViewDelegate.h"
#import "OBBaseTestCase.h"
#import "OBIngredientGauge.h"
#import <OCMock/OCMock.h>
#import "OBHopAdditionTableViewCell.h"
#import "OBHopAddition.h"
#import "OBHopFinderViewController.h"
#import "OBHopAdditionSettingsViewController.h"
#import "OBTableViewPlaceholderLabel.h"

@interface OBHopAdditionViewControllerTest : OBBaseTestCase
@property (nonatomic) OBHopAdditionViewController *vc;
@end

@implementation OBHopAdditionViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"hopAdditions"];
  self.vc.settings = self.settings;
  self.vc.recipe = self.recipe;
}

- (void)tearDown {
  self.vc = nil;

  [super tearDown];
}

- (void)testViewDidLoad_settingsIsSet
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertEqual(self.settings, self.vc.settings);
}

- (void)testViewDidLoad_tableViewDelegateIsSetup
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertNotNil(self.vc.tableViewDelegate);
  XCTAssertEqual(self.vc.tableViewDelegate, self.vc.tableView.delegate);
  XCTAssertEqual(self.vc.tableViewDelegate, self.vc.tableView.dataSource);

  XCTAssertEqual(self.vc.tableViewDelegate.recipe, self.recipe);
  XCTAssertEqual(self.vc.recipe, self.recipe);
}

- (void)testViewDidLoad_gaugeIsSetupWithStoredSettings
{
  self.settings.hopGaugeDisplayMetric = @(OBMetricBuToGuRatio);

  [self.vc loadView];
  [self.vc viewDidLoad];
  XCTAssertEqual(OBMetricBuToGuRatio, self.vc.gauge.metricToDisplay);

  self.settings.hopGaugeDisplayMetric = @(OBMetricIbu);
  [self.vc viewDidLoad];
  XCTAssertEqual(OBMetricIbu, self.vc.gauge.metricToDisplay);
}

- (void)testViewDidLoad_hopAdditionMetricUsesStoredSettings
{
  self.settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricIbu);

  [self.vc loadView];
  [self.vc viewDidLoad];
  XCTAssertEqual(OBHopAdditionMetricIbu, self.vc.tableViewDelegate.hopAdditionMetricToDisplay);

  self.settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricWeight);
  [self.vc viewDidLoad];
  XCTAssertEqual(OBHopAdditionMetricWeight, self.vc.tableViewDelegate.hopAdditionMetricToDisplay);
}

- (void)testViewDidLoad_infoButtonIsSetup
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];

  [self.vc loadView];
  [self.vc viewDidLoad];

  UIButton *button = (UIButton *)self.vc.infoButton.customView;
  XCTAssertNotNil(button);
  XCTAssertEqual(UIButtonTypeInfoDark, button.buttonType);

  [[mockVc expect] performSegueWithIdentifier:@"hopAdditionSettings" sender:self.vc];

  [button sendActionsForControlEvents:UIControlEventTouchUpInside];

  [mockVc verify];
}

- (void)testViewDidLoad_tableViewHasCorrectData
{
  [self addHops:@"Cascade" quantity:1.3 aaPercent:8.5 boilTime:60];
  [self addHops:@"Zeus" quantity:2.0 aaPercent:13.0 boilTime:60];

  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertEqual(2, [self.vc.tableView numberOfRowsInSection:0]);

  OBHopAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];

  XCTAssertEqualObjects(@"Cascade", cell.hopVariety.text);
  XCTAssertEqualObjects(@"1.3 oz", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"8.5%", cell.alphaAcid.text);
  XCTAssertEqualObjects(@"60", cell.boilTime.text);
  XCTAssertEqualObjects(@"min", cell.boilUnits.text);

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"Zeus", cell.hopVariety.text);
  XCTAssertEqualObjects(@"2.0 oz", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"13.0%", cell.alphaAcid.text);
  XCTAssertEqualObjects(@"60", cell.boilTime.text);
  XCTAssertEqualObjects(@"min", cell.boilUnits.text);
}

- (void)testViewDidLoad_gaugeRefreshes
{
  [self.vc loadView];

  self.settings.hopGaugeDisplayMetric = @(OBMetricBuToGuRatio);

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];

  [[mockGauge expect] setRecipe:self.recipe];
  [[mockGauge expect] setMetricToDisplay:OBMetricBuToGuRatio];

  [self.vc viewDidLoad];

  [mockGauge verify];
}

- (void)testViewUpdatesWhenHopAdditionsChange
{
  OBHopAddition *hopAddition = [self addHops:@"Cascade" quantity:1.3 aaPercent:8.5 boilTime:60];

  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);

  OBHopAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Cascade", cell.hopVariety.text);
  XCTAssertEqualObjects(@"1.3 oz", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"8.5%", cell.alphaAcid.text);
  XCTAssertEqualObjects(@"60", cell.boilTime.text);
  XCTAssertEqualObjects(@"min", cell.boilUnits.text);

  hopAddition.quantityInOunces = @(5.0);

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Cascade", cell.hopVariety.text);
  XCTAssertEqualObjects(@"5.0 oz", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"8.5%", cell.alphaAcid.text);
  XCTAssertEqualObjects(@"60", cell.boilTime.text);
  XCTAssertEqualObjects(@"min", cell.boilUnits.text);
}

- (void)testDeleteHopAddition
{
  [self addHops:@"Cascade" quantity:1.3 aaPercent:8.5 boilTime:60];
  OBHopAddition *hopAddition2 = [self addHops:@"Centennial" quantity:0.5 aaPercent:10 boilTime:60];

  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];
  [[mockGauge expect] refresh];

  XCTAssertEqual(2, [self.vc.tableView numberOfRowsInSection:0]);

  [self.vc.tableViewDelegate tableView:self.vc.tableView
                    commitEditingStyle:UITableViewCellEditingStyleDelete
                     forRowAtIndexPath:self.r0s0];

  [mockGauge verify];

  XCTAssertEqualObjects((@[ hopAddition2 ]), [self.recipe hopAdditionsSorted]);
  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertNil(self.vc.tableView.tableFooterView);

  OBHopAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Centennial", cell.hopVariety.text);
  XCTAssertEqualObjects(@"0.5 oz", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"10.0%", cell.alphaAcid.text);
  XCTAssertEqualObjects(@"60", cell.boilTime.text);
  XCTAssertEqualObjects(@"min", cell.boilUnits.text);
}

- (void)testDeletingLastHopAdditionShowsPlaceholderView
{
  [self addHops:@"Cascade" quantity:1.3 aaPercent:8.5 boilTime:60];

  [self.vc loadView];
  [self.vc viewDidLoad];
  [self.vc viewWillAppear:NO];

  XCTAssertNil(self.vc.tableView.tableFooterView);

  [self.vc.tableViewDelegate tableView:self.vc.tableView
                    commitEditingStyle:UITableViewCellEditingStyleDelete
                     forRowAtIndexPath:self.r0s0];

  OBTableViewPlaceholderLabel *placeHolderLabel = (id)self.vc.tableView.tableFooterView;
  XCTAssertEqualObjects(@"No Hops", placeHolderLabel.text);
}

// Hops should be added via KVO
- (void)testAddHop
{
  [self.vc loadView];
  [self.vc viewDidLoad];
  [self.vc viewWillAppear:YES];

  XCTAssertEqual(0, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertNotNil(self.vc.tableView.tableFooterView);

  [self addHops:@"Cascade" quantity:1.3 aaPercent:8.5 boilTime:60];
  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertNil(self.vc.tableView.tableFooterView, @"Placeholder view should have been removed");

  OBHopAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Cascade", cell.hopVariety.text);
  XCTAssertEqualObjects(@"1.3 oz", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"8.5%", cell.alphaAcid.text);
  XCTAssertEqualObjects(@"60", cell.boilTime.text);
  XCTAssertEqualObjects(@"min", cell.boilUnits.text);

  // Add some more hops
  [self addHops:@"Centennial" quantity:0.5 aaPercent:10 boilTime:60];

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Cascade", cell.hopVariety.text);
  XCTAssertEqualObjects(@"1.3 oz", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"8.5%", cell.alphaAcid.text);
  XCTAssertEqualObjects(@"60", cell.boilTime.text);
  XCTAssertEqualObjects(@"min", cell.boilUnits.text);

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"Centennial", cell.hopVariety.text);
  XCTAssertEqualObjects(@"0.5 oz", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"10.0%", cell.alphaAcid.text);
  XCTAssertEqualObjects(@"60", cell.boilTime.text);
  XCTAssertEqualObjects(@"min", cell.boilUnits.text);
}

- (void)testGaugeDisplaySettingsChanged
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];
  [[mockGauge expect] setMetricToDisplay:OBMetricColor];

  self.settings.hopGaugeDisplayMetric = @(OBMetricColor);

  [mockGauge verify];
}

- (void)testHopAdditionDisplaySettingChanged
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockDelegate = [OCMockObject partialMockForObject:self.vc.tableViewDelegate];
  [[mockDelegate expect] setHopAdditionMetricToDisplay:OBHopAdditionMetricIbu];

  self.settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricIbu);

  [mockDelegate verify];
}

- (void)testViewWillAppear_WhenEmpty
{
  [self.vc loadView];
  [self.vc viewDidLoad];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Hop Addition Screen", self.vc.screenName);

  OBTableViewPlaceholderLabel *placeHolderLabel = (id)self.vc.tableView.tableFooterView;
  XCTAssertEqualObjects(@"No Hops", placeHolderLabel.text);
}

- (void)testViewWillAppear_WhenThereAreHops
{
  [self addHops:@"Cascade" quantity:1.3 aaPercent:8.5 boilTime:60];

  [self.vc loadView];
  [self.vc viewDidLoad];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Hop Addition Screen", self.vc.screenName);
  XCTAssertNil(self.vc.tableView.tableFooterView);
}

- (void)testPrepareForSegue_HopFinder
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  OBHopFinderViewController *hopFinder = [[OBHopFinderViewController alloc] init];
  hopFinder.recipe = nil;

  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"addHops"
                                                                    source:self.vc
                                                               destination:hopFinder];

  [self.vc prepareForSegue:segue sender:nil];

  XCTAssertNotNil(hopFinder.recipe);
  XCTAssertEqual(self.vc.recipe, hopFinder.recipe);
}

- (void)testPrepareForSegue_HopSettings
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  OBHopAdditionSettingsViewController *settingsVc = [[OBHopAdditionSettingsViewController alloc] init];
  settingsVc.settings = nil;

  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"hopAdditionSettings"
                                                                    source:self.vc
                                                               destination:settingsVc];

  [self.vc prepareForSegue:segue sender:nil];

  XCTAssertNotNil(settingsVc.settings);
  XCTAssertEqual(self.vc.settings, settingsVc.settings);
}

- (void)testViewWillDissappear
{
  [self.vc loadView];

  self.vc.tableView.editing = YES;
  [self.vc viewWillDisappear:NO];

  XCTAssertEqual(NO, self.vc.tableView.editing);
}

@end
