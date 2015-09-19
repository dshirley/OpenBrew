//
//  OBGaugeViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/19/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBGaugeViewController.h"
#import <OCMock/OCMock.h>
#import "OBMaltAddition.h"
#import "OBHopAddition.h"
#import "OBColorView.h"

@interface OBGaugeViewControllerTest : OBBaseTestCase
@property (nonatomic) OBGaugeViewController *vc;
@end

@implementation OBGaugeViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"gaugeViewController"];
  self.vc.recipe = self.recipe;

  XCTAssertEqual(self.recipe, self.vc.recipe);
}

// All IBOutlets should be populated
- (void)testLoadView
{
  [self.vc loadView];

  XCTAssertNotNil(self.vc.valueLabel);
  XCTAssertNotNil(self.vc.descriptionLabel);
  XCTAssertNotNil(self.vc.colorView);
  XCTAssertEqual(self.recipe, self.vc.recipe);
}

- (void)testSetIbuFormula
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  self.vc.ibuFormula = OBIbuFormulaRager;

  [mockVc verify];

  XCTAssertEqual(self.vc.ibuFormula, OBIbuFormulaRager);
}

- (void)testSetRecipe
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  self.vc.recipe = self.recipe;

  [mockVc verify];

  XCTAssertEqual(self.vc.recipe, self.recipe);
}

- (void)testSetMetricToDisplay
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  self.vc.metricToDisplay = OBMetricFinalGravity;

  [mockVc verify];

  XCTAssertEqual(self.vc.metricToDisplay, OBMetricFinalGravity);
}

- (void)testRefresh_onMaltAddition
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestRefresh_onMaltAddition:(OBGaugeMetric)i];
  }
}

- (void)doTestRefresh_onMaltAddition:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self addMalt:@"Maris Otter" quantity:1.0];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onMaltDelete
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestRefresh_onMaltAddition:(OBGaugeMetric)i];
  }
}

- (void)doTestRefresh_onMaltDeletion:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self.recipe.maltAdditions delete:malt];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onMaltValueChange
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestRefresh_onMaltAddition:(OBGaugeMetric)i];
  }
}

- (void)doTestRefresh_onMaltValueChange:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  malt.quantityInPounds = @(99.987);

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onHopAddition
{
  [self doTestRefresh_onHopAddition:OBMetricIbu];
  [self doTestRefresh_onHopAddition:OBMetricBuToGuRatio];
}

- (void)doTestRefresh_onHopAddition:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self addHops:@"Cascade" quantity:1.0 aaPercent:7.0 boilTime:60];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onHopDeletion
{
  [self doTestRefresh_onHopDeletion:OBMetricIbu];
  [self doTestRefresh_onHopDeletion:OBMetricBuToGuRatio];
}

- (void)doTestRefresh_onHopDeletion:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  OBHopAddition *hops = [self addHops:@"Cascade" quantity:1.0 aaPercent:7.0 boilTime:60];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  hops.recipe = nil;

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onHopValueChange
{
  [self doTestRefresh_onHopValueChange:OBMetricIbu];
  [self doTestRefresh_onHopValueChange:OBMetricBuToGuRatio];
}

- (void)doTestRefresh_onHopValueChange:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  OBHopAddition *hops = [self addHops:@"Cascade" quantity:1.0 aaPercent:7.0 boilTime:60];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];
  [[mockVc expect] refresh];
  [[mockVc expect] refresh];

  hops.quantityInOunces = @(2.0);
  hops.alphaAcidPercent = @(5.0);
  hops.boilTimeInMinutes = @(50);

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onYeastAddition
{
  [self doTestRefresh_onYeastAddition:OBMetricFinalGravity];
  [self doTestRefresh_onYeastAddition:OBMetricAbv];
}

- (void)doTestRefresh_onYeastAddition:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self addYeast:@"WLP001"];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onYeastDeletion
{
  [self doTestRefresh_onYeastDeletion:OBMetricFinalGravity];
  [self doTestRefresh_onYeastDeletion:OBMetricAbv];
}

- (void)doTestRefresh_onYeastDeletion:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  [self addYeast:@"WLP001"];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  self.recipe.yeast = nil;

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onYeastValueChange
{
  [self doTestRefresh_onYeastValueChange:OBMetricFinalGravity];
  [self doTestRefresh_onYeastValueChange:OBMetricAbv];
}

- (void)doTestRefresh_onYeastValueChange:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  [self addYeast:@"WLP001"];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self addYeast:@"WLP002"];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onPreBoilSizeChange
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestRefresh_onPreBoilSizeChange:(OBGaugeMetric)i];
  }
}

- (void)doTestRefresh_onPreBoilSizeChange:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  self.recipe.preBoilVolumeInGallons = @(999.0);

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testRefresh_onPostBoilSizeChange
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestRefresh_onPostBoilSizeChange:(OBGaugeMetric)i];
  }
}

- (void)doTestRefresh_onPostBoilSizeChange:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  self.recipe.postBoilVolumeInGallons = @(999.0);

  [mockVc verify];
  [mockVc stopMocking];
}

@end
