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

  OBMaltAdditionTableViewCell *cell = [self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Acid Malt", cell.maltVariety.text);
  XCTAssertEqualObjects(@"1lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"4 Lovibond", cell.color.text);

  cell = [self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"Two-Row", cell.maltVariety.text);
  XCTAssertEqualObjects(@"10lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"2 Lovibond", cell.color.text);
}

- (void)testViewDidLoad_gaugeRefreshes
{
  self.brewery.maltAdditionDisplayMetric = @(OBMetricOriginalGravity);

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];
  [[mockGauge expect] refresh];

  [self.vc loadView];
  [self.vc viewDidLoad];

  [mockGauge verify];
}

- (void)testViewUpdatesWhenMaltAdditionsChange
{
  OBMaltAddition *maltAddition = [self addMalt:@"Two-Row" quantity:10.0 color:2];

  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);

  OBMaltAdditionTableViewCell *cell = [self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Two-Row", cell.maltVariety.text);
  XCTAssertEqualObjects(@"10lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"2 Lovibond", cell.color.text);

  maltAddition.quantityInPounds = @(5.0);

  cell = [self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Two-Row", cell.maltVariety.text);
  XCTAssertEqualObjects(@"5lb", cell.primaryMetric.text);
  XCTAssertEqualObjects(@"2 Lovibond", cell.color.text);
}

// TODO:  add a test for deleting a malt addition

// TODO:  add a test for adding a malt

// TODO:  test changing the brewery settings for the gauge

// TODO:  test changing the brewery settings for the primary metric

// TODO:  test view will appear

// TODO:  test prepare for segue - malt finder

// TODO:  test prepare for segue - malt settings

// TODO:  test observe value for key path

@end
