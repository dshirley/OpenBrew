//
//  OBHopAdditionSettingsViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBHopAdditionSettingsViewController.h"
#import "OBSegmentedController.h"
#import "OBBaseTestCase.h"
#import <OCMock/OCMock.h>

@interface OBHopAdditionSettingsViewControllerTest : OBBaseTestCase
@property (nonatomic) OBHopAdditionSettingsViewController *vc;

@end

@implementation OBHopAdditionSettingsViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"hopSettings"];
  self.vc.settings = self.settings;
}

- (void)testWillAppear
{
  self.settings.hopGaugeDisplayMetric = @(OBMetricBuToGuRatio);
  self.settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricIbu);

  [self.vc loadView];
  [self.vc viewWillAppear:NO];

  XCTAssertNotNil(self.vc.gaugeDisplaySettingController);
  XCTAssertNotNil(self.vc.ingredientDisplaySettingController);

  // Make sure the gauge display setting is setup properly
  UISegmentedControl *gaugeSegmentedControl = self.vc.gaugeDisplaySettingController.segmentedControl;
  XCTAssertNotNil(gaugeSegmentedControl);
  XCTAssertEqual(2, [gaugeSegmentedControl numberOfSegments]);
  XCTAssertEqualObjects(@"IBU", [gaugeSegmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@"Bitterness : Gravity", [gaugeSegmentedControl titleForSegmentAtIndex:1]);
  XCTAssertEqual(1, [gaugeSegmentedControl selectedSegmentIndex]);

  // Make sure the ingredient display setting is setup properly
  UISegmentedControl *ingredientSegmentedControl = self.vc.ingredientDisplaySettingController.segmentedControl;
  XCTAssertNotNil(ingredientSegmentedControl);
  XCTAssertEqual(2, [ingredientSegmentedControl numberOfSegments]);
  XCTAssertEqualObjects(@"Weight", [ingredientSegmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@"IBU", [ingredientSegmentedControl titleForSegmentAtIndex:1]);
  XCTAssertEqual(1, [ingredientSegmentedControl selectedSegmentIndex]);

  // Make sure both segmented controllers are wired up to change our settings settings
  [gaugeSegmentedControl setSelectedSegmentIndex:0];
  [gaugeSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
  XCTAssertEqualObjects(@(OBMetricIbu), self.settings.hopGaugeDisplayMetric);

  [ingredientSegmentedControl setSelectedSegmentIndex:0];
  [ingredientSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
  XCTAssertEqualObjects(@(OBHopAdditionMetricWeight), self.settings.hopAdditionDisplayMetric);
}

- (void)testGreyAreaTouchDown {
  [self.vc loadView];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] performSegueWithIdentifier:@"dismissSettingsView" sender:self.vc];

  [self.vc.greyoutButton sendActionsForControlEvents:UIControlEventTouchDown];

  [mockVc verify];
}

@end
