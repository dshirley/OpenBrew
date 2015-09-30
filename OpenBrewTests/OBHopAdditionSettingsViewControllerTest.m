//
//  OBHopAdditionSettingsViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBHopAdditionSettingsViewController.h"
#import "OBBaseTestCase.h"
#import <OCMock/OCMock.h>
#import "OBHopWeightSegmentedControlDelegate.h"
#import "OBIbuFormulaSegmentedControlDelegate.h"

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

- (void)testViewDidLoad
{
  self.settings.hopGaugeDisplayMetric = @(OBMetricBuToGuRatio);
  self.settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricIbu);

  (void)self.vc.view;

  OBHopWeightSegmentedControlDelegate *weightDelegate = self.vc.unitsSegmentedControl.delegate;
  XCTAssertNotNil(weightDelegate);
  XCTAssertEqualObjects(NSStringFromClass(OBHopWeightSegmentedControlDelegate.class),
                        NSStringFromClass(weightDelegate.class));
  XCTAssertEqual(self.settings, weightDelegate.settings);

  OBIbuFormulaSegmentedControlDelegate *ibuDelegate = self.vc.ibuFormulaSegmentedControl.delegate;
  XCTAssertNotNil(ibuDelegate);
  XCTAssertEqualObjects(NSStringFromClass(OBIbuFormulaSegmentedControlDelegate.class),
                        NSStringFromClass(ibuDelegate.class));
  XCTAssertEqual(self.settings, ibuDelegate.settings);
}

- (void)testGreyAreaTouchDown {
  [self.vc loadView];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] performSegueWithIdentifier:@"dismissSettingsView" sender:self.vc];

  [self.vc.greyoutButton sendActionsForControlEvents:UIControlEventTouchDown];

  [mockVc verify];
}

@end
