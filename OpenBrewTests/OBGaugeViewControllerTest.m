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

- (void)testKvo_onMaltAddition
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestKvo_onMaltAddition:(OBGaugeMetric)i];
  }
}

- (void)doTestKvo_onMaltAddition:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self addMalt:@"Maris Otter" quantity:1.0];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testKvo_onMaltDelete
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestKvo_onMaltAddition:(OBGaugeMetric)i];
  }
}

- (void)doTestKvo_onMaltDeletion:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self.recipe.maltAdditions delete:malt];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testKvo_onMaltValueChange
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestKvo_onMaltAddition:(OBGaugeMetric)i];
  }
}

- (void)doTestKvo_onMaltValueChange:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  malt.quantityInPounds = @(99.987);

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testKvo_onHopAddition
{
  [self doTestKvo_onHopAddition:OBMetricIbu];
  [self doTestKvo_onHopAddition:OBMetricBuToGuRatio];
}

- (void)doTestKvo_onHopAddition:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self addHops:@"Cascade" quantity:1.0 aaPercent:7.0 boilTime:60];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testKvo_onHopDeletion
{
  [self doTestKvo_onHopDeletion:OBMetricIbu];
  [self doTestKvo_onHopDeletion:OBMetricBuToGuRatio];
}

- (void)doTestKvo_onHopDeletion:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  OBHopAddition *hops = [self addHops:@"Cascade" quantity:1.0 aaPercent:7.0 boilTime:60];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  hops.recipe = nil;

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testKvo_onHopValueChange
{
  [self doTestKvo_onHopValueChange:OBMetricIbu];
  [self doTestKvo_onHopValueChange:OBMetricBuToGuRatio];
}

- (void)doTestKvo_onHopValueChange:(OBGaugeMetric)metric
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

- (void)testKvo_onYeastAddition
{
  [self doTestKvo_onYeastAddition:OBMetricFinalGravity];
  [self doTestKvo_onYeastAddition:OBMetricAbv];
}

- (void)doTestKvo_onYeastAddition:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self addYeast:@"WLP001"];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testKvo_onYeastDeletion
{
  [self doTestKvo_onYeastDeletion:OBMetricFinalGravity];
  [self doTestKvo_onYeastDeletion:OBMetricAbv];
}

- (void)doTestKvo_onYeastDeletion:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  [self addYeast:@"WLP001"];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  self.recipe.yeast = nil;

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testKvo_onYeastValueChange
{
  [self doTestKvo_onYeastValueChange:OBMetricFinalGravity];
  [self doTestKvo_onYeastValueChange:OBMetricAbv];
}

- (void)doTestKvo_onYeastValueChange:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  [self addYeast:@"WLP001"];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  [self addYeast:@"WLP002"];

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testKvo_onPreBoilSizeChange
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestKvo_onPreBoilSizeChange:(OBGaugeMetric)i];
  }
}

- (void)doTestKvo_onPreBoilSizeChange:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  self.recipe.preBoilVolumeInGallons = @(999.0);

  [mockVc verify];
  [mockVc stopMocking];
}

- (void)testKvo_onPostBoilSizeChange
{
  for (int i = 0; i < OBMetricNumberOfMetrics; i++) {
    [self doTestKvo_onPostBoilSizeChange:(OBGaugeMetric)i];
  }
}

- (void)doTestKvo_onPostBoilSizeChange:(OBGaugeMetric)metric
{
  self.vc.metricToDisplay = metric;

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] refresh];

  self.recipe.postBoilVolumeInGallons = @(999.0);

  [mockVc verify];
  [mockVc stopMocking];
}

// Returns a mock recipe that can be set as the recipe of the view controller.
// The view controller registers observers and the mock has to be prepared to
// handle that.
- (id)mockRecipe
{
  id mockRecipe = [OCMockObject mockForClass:OBRecipe.class];
  [[mockRecipe expect] addObserver:self.vc forKeyPath:@"originalGravity" options:0 context:nil];
  [[mockRecipe expect] addObserver:self.vc forKeyPath:@"IBUs:" options:0 context:nil];
  [[mockRecipe expect] addObserver:self.vc forKeyPath:@"postBoilVolumeInGallons" options:0 context:nil];
  [[mockRecipe expect] addObserver:self.vc forKeyPath:@"preBoilVolumeInGallons" options:0 context:nil];
  return mockRecipe;
}

- (void)testRefresh_originalGravity_noAnimate
{
  self.vc.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.vc.valueLabel = [[UICountingLabel alloc] initWithFrame:CGRectZero];
  self.vc.metricToDisplay = OBMetricOriginalGravity;
  self.vc.willAnimateNextRefresh = NO;
  
  id mockRecipe = [self mockRecipe];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float) 1.050)] originalGravity];

  id mockValueLabel = [OCMockObject partialMockForObject:self.vc.valueLabel];
  [[mockValueLabel expect] setText:@"1.050"];

  // This should call refresh
  self.vc.recipe = mockRecipe;

  [mockRecipe verify];
  [mockValueLabel verify];
  XCTAssertTrue(self.vc.willAnimateNextRefresh);
  XCTAssertEqualObjects(@"Original gravity", self.vc.descriptionLabel.text);
}

- (void)testRefresh_originalGravity_animate
{
  self.vc.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.vc.valueLabel = [[UICountingLabel alloc] initWithFrame:CGRectZero];
  self.vc.metricToDisplay = OBMetricOriginalGravity;
  self.vc.willAnimateNextRefresh = YES;

  id mockRecipe = [self mockRecipe];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float) 1.060)] originalGravity];

  id mockValueLabel = [OCMockObject partialMockForObject:self.vc.valueLabel];
  [[[mockValueLabel stub] andReturnValue:OCMOCK_VALUE((float) 1.050)] currentValue];
  [[mockValueLabel expect] countFrom:1.050 to:1.060 withDuration:0.25];

  // This will call refresh
  self.vc.recipe = mockRecipe;

  [mockRecipe verify];
  [mockValueLabel verify];
  XCTAssertTrue(self.vc.willAnimateNextRefresh);
  XCTAssertEqualObjects(@"Original gravity", self.vc.descriptionLabel.text);
  XCTAssertEqualObjects(@"%.3f", self.vc.valueLabel.format);
}

- (void)testRefresh_finalGravity_noAnimate
{
  self.vc.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.vc.valueLabel = [[UICountingLabel alloc] initWithFrame:CGRectZero];
  self.vc.metricToDisplay = OBMetricFinalGravity;
  self.vc.willAnimateNextRefresh = NO;

  id mockRecipe = [self mockRecipe];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float) 1.005)] finalGravity];

  id mockValueLabel = [OCMockObject partialMockForObject:self.vc.valueLabel];
  [[mockValueLabel expect] setText:@"1.005"];

  // This should call refresh
  self.vc.recipe = mockRecipe;

  [mockRecipe verify];
  [mockValueLabel verify];
  XCTAssertTrue(self.vc.willAnimateNextRefresh);
  XCTAssertEqualObjects(@"Final gravity", self.vc.descriptionLabel.text);
}

- (void)testRefresh_finalGravity_animate
{
  self.vc.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.vc.valueLabel = [[UICountingLabel alloc] initWithFrame:CGRectZero];
  self.vc.metricToDisplay = OBMetricFinalGravity;
  self.vc.willAnimateNextRefresh = YES;

  id mockRecipe = [self mockRecipe];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float) 1.005)] finalGravity];

  id mockValueLabel = [OCMockObject partialMockForObject:self.vc.valueLabel];
  [[[mockValueLabel stub] andReturnValue:OCMOCK_VALUE((float) 1.010)] currentValue];
  [[mockValueLabel expect] countFrom:1.010 to:1.005 withDuration:0.25];

  // This will call refresh
  self.vc.recipe = mockRecipe;

  [mockRecipe verify];
  [mockValueLabel verify];
  XCTAssertTrue(self.vc.willAnimateNextRefresh);
  XCTAssertEqualObjects(@"Final gravity", self.vc.descriptionLabel.text);
  XCTAssertEqualObjects(@"%.3f", self.vc.valueLabel.format);
}

- (void)testRefresh_abv_noAnimate
{
  self.vc.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.vc.valueLabel = [[UICountingLabel alloc] initWithFrame:CGRectZero];
  self.vc.metricToDisplay = OBMetricAbv;
  self.vc.willAnimateNextRefresh = NO;

  id mockRecipe = [self mockRecipe];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float) 5.3)] alcoholByVolume];

  id mockValueLabel = [OCMockObject partialMockForObject:self.vc.valueLabel];

  // TODO: ABV should be displayed with a %
  [[mockValueLabel expect] setText:@"5.3"];

  // This should call refresh
  self.vc.recipe = mockRecipe;

  [mockRecipe verify];
  [mockValueLabel verify];
  XCTAssertTrue(self.vc.willAnimateNextRefresh);
  XCTAssertEqualObjects(@"ABV", self.vc.descriptionLabel.text);
}

- (void)testRefresh_abv_animate
{
  self.vc.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.vc.valueLabel = [[UICountingLabel alloc] initWithFrame:CGRectZero];
  self.vc.metricToDisplay = OBMetricAbv;
  self.vc.willAnimateNextRefresh = YES;

  id mockRecipe = [self mockRecipe];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float) 5.3)] alcoholByVolume];

  id mockValueLabel = [OCMockObject partialMockForObject:self.vc.valueLabel];
  [[[mockValueLabel stub] andReturnValue:OCMOCK_VALUE((float) 6.89)] currentValue];
  [[mockValueLabel expect] countFrom:6.89 to:5.3 withDuration:0.25];

  // This will call refresh
  self.vc.recipe = mockRecipe;

  [mockRecipe verify];
  [mockValueLabel verify];
  XCTAssertTrue(self.vc.willAnimateNextRefresh);
  XCTAssertEqualObjects(@"ABV", self.vc.descriptionLabel.text);
  XCTAssertEqualObjects(@"%.1f", self.vc.valueLabel.format);
}

- (void)testRefresh_color_noAnimate
{
  self.vc.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.vc.valueLabel = [[UICountingLabel alloc] initWithFrame:CGRectZero];
  self.vc.colorView = [[OBColorView alloc] initWithFrame:CGRectZero];
  self.vc.metricToDisplay = OBMetricColor;

  // TODO: there's a selector called colorInSrm -> SRM should be all caps
  id mockRecipe = [self mockRecipe];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float) 15)] colorInSRM];

  // This should call refresh
  self.vc.recipe = mockRecipe;

  [mockRecipe verify];

  XCTAssertTrue(self.vc.willAnimateNextRefresh);
  XCTAssertTrue(self.vc.valueLabel.hidden);
  XCTAssertFalse(self.vc.colorView.hidden);
  XCTAssertEqualObjects(@"15 SRM", self.vc.descriptionLabel.text);
  XCTAssertEqual(15, self.vc.colorView.colorInSrm);
}


@end
