//
//  OBMaltDisplayMetricSegmentedControlDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBSettings.h"
#import "OBBaseTestCase.h"
#import "OBMaltDisplayMetricSegmentedControlDelegate.h"

@interface OBMaltDisplayMetricSegmentedControlDelegateTest : OBBaseTestCase
@property (nonatomic) OBMaltDisplayMetricSegmentedControlDelegate *delegate;
@end

@implementation OBMaltDisplayMetricSegmentedControlDelegateTest

- (void)setUp {
  [super setUp];

  self.delegate = [[OBMaltDisplayMetricSegmentedControlDelegate alloc] initWithSettings:self.settings];
}

- (void)testSegmentTitles
{
  XCTAssertEqualObjects((@[ @"Weight", @"%" ]), [self.delegate segmentTitlesForSegmentedControl:nil]);
}

- (void)testSegmentSelected
{
  self.settings.maltAdditionDisplayMetric = @(OBMaltAdditionMetricPercentOfGravity);

  [self.delegate segmentedControl:nil segmentSelected:0];
  XCTAssertEqualObjects(@(OBMaltAdditionMetricWeight), self.settings.maltAdditionDisplayMetric);

  [self.delegate segmentedControl:nil segmentSelected:1];
  XCTAssertEqualObjects(@(OBMaltAdditionMetricPercentOfGravity), self.settings.maltAdditionDisplayMetric);
}

- (void)testInitiallySelectedSegment
{
  self.settings.maltAdditionDisplayMetric = @(OBMaltAdditionMetricPercentOfGravity);
  XCTAssertEqual(1, [self.delegate initiallySelectedSegmentForSegmentedControl:nil]);

  self.settings.maltAdditionDisplayMetric = @(OBMaltAdditionMetricWeight);
  XCTAssertEqual(0, [self.delegate initiallySelectedSegmentForSegmentedControl:nil]);
}

@end
