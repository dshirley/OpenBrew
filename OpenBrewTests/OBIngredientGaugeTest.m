//
//  OBIngredientGauge.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/4/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBIngredientGauge.h"
#import "OBBaseTestCase.h"
#import "OBColorView.h"
#import <OCMock/OCMock.h>

@interface OBIngredientGauge(Testing)
@property (weak, nonatomic) UILabel *valueLabel;
@property (weak, nonatomic) UILabel *descriptionLabel;
@property (weak, nonatomic) OBColorView *colorView;
@end


@interface OBIngredientGaugeTest : OBBaseTestCase

@end

@implementation OBIngredientGaugeTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

// This is mostly just making sure that the nib loads
- (void)testInit
{
  OBIngredientGauge *gauge = [[OBIngredientGauge alloc] initWithFrame:CGRectZero];

  XCTAssertNil(gauge.recipe);
  XCTAssertEqual(0, gauge.metricToDisplay);
  XCTAssertNotNil(gauge.valueLabel);
  XCTAssertNotNil(gauge.descriptionLabel);
  XCTAssertNotNil(gauge.colorView);
}

- (void)testSetRecipe
{
  OBIngredientGauge *gauge = [[OBIngredientGauge alloc] initWithFrame:CGRectZero];
  id mockGauge = [OCMockObject partialMockForObject:gauge];
  [[mockGauge expect] refresh];

  gauge.recipe = self.recipe;

  [mockGauge verify];

  XCTAssertEqual(gauge.recipe, self.recipe);
}

- (void)testSetMetricToDisplay
{
  OBIngredientGauge *gauge = [[OBIngredientGauge alloc] initWithFrame:CGRectZero];
  id mockGauge = [OCMockObject partialMockForObject:gauge];
  [[mockGauge expect] refresh];

  gauge.metricToDisplay = OBMetricFinalGravity;

  [mockGauge verify];

  XCTAssertEqual(gauge.metricToDisplay, OBMetricFinalGravity);
}

- (void)testRefresh_originalGravity
{
  OBIngredientGauge *gauge = [[OBIngredientGauge alloc] initWithFrame:CGRectZero];

  id mockRecipe = [OCMockObject mockForClass:[OBRecipe class]];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)1.23)] originalGravity];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)15)] colorInSRM];

  gauge.metricToDisplay = OBMetricOriginalGravity;
  gauge.recipe = mockRecipe;

  XCTAssertEqualObjects(@"1.230", gauge.valueLabel.text);
  XCTAssertEqualObjects(@"Original gravity", gauge.descriptionLabel.text);
  XCTAssertTrue(gauge.colorView.hidden);
}

- (void)testRefresh_finalGravity
{
  OBIngredientGauge *gauge = [[OBIngredientGauge alloc] initWithFrame:CGRectZero];

  id mockRecipe = [OCMockObject mockForClass:[OBRecipe class]];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)2.031)] finalGravity];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)15)] colorInSRM];

  gauge.metricToDisplay = OBMetricFinalGravity;
  gauge.recipe = mockRecipe;

  XCTAssertEqualObjects(@"2.031", gauge.valueLabel.text);
  XCTAssertEqualObjects(@"Final gravity", gauge.descriptionLabel.text);
  XCTAssertTrue(gauge.colorView.hidden);
}

- (void)testRefresh_abv
{
  OBIngredientGauge *gauge = [[OBIngredientGauge alloc] initWithFrame:CGRectZero];

  id mockRecipe = [OCMockObject mockForClass:[OBRecipe class]];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)7.9876)] alcoholByVolume];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)15)] colorInSRM];

  gauge.metricToDisplay = OBMetricAbv;
  gauge.recipe = mockRecipe;

  XCTAssertEqualObjects(@"8.0%", gauge.valueLabel.text);
  XCTAssertEqualObjects(@"ABV", gauge.descriptionLabel.text);
  XCTAssertTrue(gauge.colorView.hidden);
}

- (void)testRefresh_color
{
  OBIngredientGauge *gauge = [[OBIngredientGauge alloc] initWithFrame:CGRectZero];

  id mockRecipe = [OCMockObject mockForClass:[OBRecipe class]];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)15.63)] colorInSRM];

  gauge.metricToDisplay = OBMetricColor;
  gauge.recipe = mockRecipe;

  XCTAssertEqualObjects(@"", gauge.valueLabel.text);
  XCTAssertEqualObjects(@"16 SRM", gauge.descriptionLabel.text);
  XCTAssertFalse(gauge.colorView.hidden);
}

- (void)testRefresh_ibu
{
  OBIngredientGauge *gauge = [[OBIngredientGauge alloc] initWithFrame:CGRectZero];

  id mockRecipe = [OCMockObject mockForClass:[OBRecipe class]];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)9.123)] IBUs];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)15.63)] colorInSRM];

  gauge.metricToDisplay = OBMetricIbu;
  gauge.recipe = mockRecipe;

  XCTAssertEqualObjects(@"9", gauge.valueLabel.text);
  XCTAssertEqualObjects(@"IBU", gauge.descriptionLabel.text);
  XCTAssertTrue(gauge.colorView.hidden);
}

- (void)testRefresh_bitteringToGravity
{
  OBIngredientGauge *gauge = [[OBIngredientGauge alloc] initWithFrame:CGRectZero];

  id mockRecipe = [OCMockObject mockForClass:[OBRecipe class]];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)99.123)] bitternessToGravityRatio];
  [[[mockRecipe stub] andReturnValue:OCMOCK_VALUE((float)15.63)] colorInSRM];

  gauge.metricToDisplay = OBMetricBuToGuRatio;
  gauge.recipe = mockRecipe;

  XCTAssertEqualObjects(@"99.12", gauge.valueLabel.text);
  XCTAssertEqualObjects(@"BU:GU", gauge.descriptionLabel.text);
  XCTAssertTrue(gauge.colorView.hidden);
}

@end
