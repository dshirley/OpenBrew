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

  self.vc = [[OBHopAdditionSettingsViewController alloc] initWithSettings:self.settings];

  XCTAssertEqual(self.settings, self.vc.settings);
}

- (void)testViewDidLoad
{
  self.settings.hopGaugeDisplayMetric = @(OBMetricBuToGuRatio);
  self.settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricIbu);

  (void)self.vc.view;

  OBIbuFormulaSegmentedControlDelegate *ibuDelegate = self.vc.ibuFormulaSegmentedControl.delegate;
  XCTAssertNotNil(ibuDelegate);
  XCTAssertEqualObjects(NSStringFromClass(OBIbuFormulaSegmentedControlDelegate.class),
                        NSStringFromClass(ibuDelegate.class));
  XCTAssertEqual(self.settings, ibuDelegate.settings);
}

@end
