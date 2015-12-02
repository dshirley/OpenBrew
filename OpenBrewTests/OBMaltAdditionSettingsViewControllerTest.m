//
//  OBMaltAdditionSettingsViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/1/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBMaltAdditionSettingsViewController.h"
#import "OBBaseTestCase.h"
#import <OCMock/OCMock.h>

@interface OBMaltAdditionSettingsViewControllerTest : OBBaseTestCase
@property (nonatomic) OBMaltAdditionSettingsViewController *vc;

@end

@implementation OBMaltAdditionSettingsViewControllerTest

- (void)setUp {
  [super setUp];

  self.vc = [[OBMaltAdditionSettingsViewController alloc] initWithRecipe:self.recipe settings:self.settings];
  XCTAssertEqual(self.recipe, self.vc.recipe);
  XCTAssertEqual(self.settings, self.vc.settings);
}

- (void)tearDown {
  [super tearDown];
}

- (void)testWillAppear
{
  self.settings.maltGaugeDisplayMetric = @(OBMetricColor);
  self.settings.maltAdditionDisplayMetric = @(OBMaltAdditionMetricPercentOfGravity);

  [self.vc loadView];
  [self.vc viewWillAppear:NO];
}

- (void)testViewWillAppearShowsCorrectMashEfficiency
{
  self.recipe.mashEfficiency = @(0.53);

  [self.vc loadView];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Efficiency: 53%", self.vc.mashEfficiencyLabel.text);
  XCTAssertEqualWithAccuracy(0.53, self.vc.mashEfficiencySlider.value, 0.00001);
}

- (void)testSliderValueChanging
{
  [self.vc loadView];
  [self.vc viewWillAppear:NO];

  XCTAssertNotEqualWithAccuracy(0.08, [self.recipe.mashEfficiency floatValue], 0.01);
  XCTAssertNotEqualObjects(@"Efficiency: 8%", self.vc.mashEfficiencyLabel.text);

  self.vc.mashEfficiencySlider.value = 0.08;
  [self.vc.mashEfficiencySlider sendActionsForControlEvents:UIControlEventValueChanged];

  XCTAssertEqualWithAccuracy(0.08, [self.recipe.mashEfficiency floatValue], 0.005);
  XCTAssertEqualObjects(@"Efficiency: 8%", self.vc.mashEfficiencyLabel.text);
}

@end
