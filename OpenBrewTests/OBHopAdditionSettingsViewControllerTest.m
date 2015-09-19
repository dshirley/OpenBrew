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

  XCTAssertNotNil(self.vc.ingredientDisplaySettingController);

  // Make sure the ingredient display setting is setup properly
  UISegmentedControl *ingredientSegmentedControl = self.vc.ingredientDisplaySettingController.segmentedControl;
  XCTAssertNotNil(ingredientSegmentedControl);
  XCTAssertEqual(2, [ingredientSegmentedControl numberOfSegments]);
  XCTAssertEqualObjects(@"Weight", [ingredientSegmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@"IBU", [ingredientSegmentedControl titleForSegmentAtIndex:1]);
  XCTAssertEqual(1, [ingredientSegmentedControl selectedSegmentIndex]);

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
