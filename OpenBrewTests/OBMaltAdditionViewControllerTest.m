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
#import "OBIngredientGauge.h"
#import <OCMock/OCMock.h>
#import "OBMaltAdditionTableViewCell.h"
#import "OBMaltAddition.h"
#import "OBMaltFinderViewController.h"
#import "OBMaltAdditionSettingsViewController.h"
#import "OBTableViewPlaceholderLabel.h"

@interface OBMaltAdditionViewControllerTest : OBBaseTestCase
@property (nonatomic) OBMaltAdditionViewController *vc;
@end

@implementation OBMaltAdditionViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"maltAdditions"];
  self.vc.brewery = self.brewery;
  self.vc.recipe = self.recipe;
}

- (void)tearDown {
//  self.vc = nil;

  [super tearDown];
}

- (void)testViewDidLoad_breweryIsSet
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertEqual(self.brewery, self.vc.brewery);
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
  self.brewery.maltGaugeDisplayMetric = @(OBMetricColor);

  [self.vc loadView];
  [self.vc viewDidLoad];
  XCTAssertEqual(OBMetricColor, self.vc.gauge.metricToDisplay);

  self.brewery.maltGaugeDisplayMetric = @(OBMetricOriginalGravity);
  [self.vc viewDidLoad];
  XCTAssertEqual(OBMetricOriginalGravity, self.vc.gauge.metricToDisplay);
}

- (void)testViewDidLoad_maltAdditionMetricUsesStoredSettings
{
  self.brewery.maltAdditionDisplayMetric = @(OBMaltAdditionMetricPercentOfGravity);

  [self.vc loadView];
  [self.vc viewDidLoad];
  XCTAssertEqual(OBMaltAdditionMetricPercentOfGravity, self.vc.tableViewDelegate.maltAdditionMetricToDisplay);

  self.brewery.maltAdditionDisplayMetric = @(OBMaltAdditionMetricWeight);
  [self.vc viewDidLoad];
  XCTAssertEqual(OBMaltAdditionMetricWeight, self.vc.tableViewDelegate.maltAdditionMetricToDisplay);
}

- (void)testViewDidLoad_infoButtonIsSetup
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];

  [self.vc loadView];
  [self.vc viewDidLoad];

  UIButton *button = (UIButton *)self.vc.infoButton.customView;
  XCTAssertNotNil(button);
  XCTAssertEqual(UIButtonTypeInfoDark, button.buttonType);

  [[mockVc expect] performSegueWithIdentifier:@"maltAdditionSettings" sender:self.vc];

  [button sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)testViewDidLoad_tableViewHasCorrectData
{
  [self addMalt:@"Acid Malt" quantity:1.0 color:4];
  [self addMalt:@"Two-Row" quantity:10.0 color:2];

  [self.vc loadView];
  [self.vc viewDidLoad];

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

- (void)testViewDidLoad_gaugeRefreshes
{
  self.brewery.maltAdditionDisplayMetric = @(OBMetricOriginalGravity);

  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];
  [[mockGauge expect] refresh];

  [mockGauge verify];
}

- (void)testViewUpdatesWhenMaltAdditionsChange
{
  OBMaltAddition *maltAddition = [self addMalt:@"Two-Row" quantity:10.0 color:2];

  [self.vc loadView];
  [self.vc viewDidLoad];

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

  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];
  [[mockGauge expect] refresh];

  XCTAssertEqual(2, [self.vc.tableView numberOfRowsInSection:0]);

  [self.vc.tableViewDelegate tableView:self.vc.tableView
                    commitEditingStyle:UITableViewCellEditingStyleDelete
                     forRowAtIndexPath:self.r0s0];

  [mockGauge verify];

  XCTAssertEqualObjects((@[ maltAddition2 ]), [self.recipe maltAdditionsSorted]);
  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);

  OBMaltAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Pilsner Malt", cell.maltVariety.text);
  XCTAssertEqualObjects(@"3lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"1 Lovibond", cell.color.text);
}

// Malts should be added via KVO
- (void)testAddMalt
{
  [self.vc loadView];
  [self.vc viewDidLoad];
  [self.vc viewWillAppear:YES];

  XCTAssertEqual(0, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertNotNil(self.vc.tableView.tableFooterView);

  [self addMalt:@"Two-Row" quantity:10.0 color:2];
  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertNil(self.vc.tableView.tableFooterView, @"Placeholder view should have been removed");

  OBMaltAdditionTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Two-Row", cell.maltVariety.text);
  XCTAssertEqualObjects(@"10lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"2 Lovibond", cell.color.text);

  [self addMalt:@"Pilsner Malt" quantity:3.0 color:1];
  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Pilsner Malt", cell.maltVariety.text);
  XCTAssertEqualObjects(@"3lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"1 Lovibond", cell.color.text);
}

- (void)testGaugeDisplaySettingsChanged
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];
  [[mockGauge expect] setMetricToDisplay:OBMetricIbu];

  [self.vc loadView];
  [self.vc viewDidLoad];

  self.brewery.maltGaugeDisplayMetric = @(OBMetricIbu);

  [mockGauge verify];
}

- (void)testMaltAdditionDisplaySettingChanged
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockDelegate = [OCMockObject partialMockForObject:self.vc.tableViewDelegate];
  [[mockDelegate expect] setMaltAdditionMetricToDisplay:OBMaltAdditionMetricPercentOfGravity];

  self.brewery.maltAdditionDisplayMetric = @(OBMaltAdditionMetricPercentOfGravity);

  [mockDelegate verify];
}

- (void)testViewWillAppear_WhenEmpty
{
  [self.vc loadView];
  [self.vc viewDidLoad];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Malt Addition Screen", self.vc.screenName);

  OBTableViewPlaceholderLabel *placeHolderLabel = (id)self.vc.tableView.tableFooterView;
  XCTAssertEqualObjects(@"No Malts", placeHolderLabel.text);
}

- (void)testViewWillAppear_WhenThereAreMalts
{
 [self addMalt:@"Two-Row" quantity:10.0 color:2];

  [self.vc loadView];
  [self.vc viewDidLoad];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Malt Addition Screen", self.vc.screenName);
  XCTAssertNil(self.vc.tableView.tableFooterView);
}

- (void)testPrepareForSegue_MaltFinder
{
  [self.vc loadView];
  [self.vc viewDidLoad];

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
  [self.vc loadView];
  [self.vc viewDidLoad];

  OBMaltAdditionSettingsViewController *settingsVc = [[OBMaltAdditionSettingsViewController alloc] init];
  settingsVc.brewery = nil;

  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"maltAdditionSettings"
                                                                    source:self.vc
                                                               destination:settingsVc];

  [self.vc prepareForSegue:segue sender:nil];

  XCTAssertNotNil(settingsVc.brewery);
  XCTAssertEqual(self.vc.brewery, settingsVc.brewery);
}

// TODO:  test observe value for key path

@end
