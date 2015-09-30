//
//  OBHopDisplayMetricSegmentedControlDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/30/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBSettings.h"
#import "OBBaseTestCase.h"
#import "OBHopDisplayMetricSegmentedControlDelegate.h"

@interface OBHopDisplayMetricSegmentedControlDelegateTest : OBBaseTestCase
@property (nonatomic) OBHopDisplayMetricSegmentedControlDelegate *delegate;
@end

@implementation OBHopDisplayMetricSegmentedControlDelegateTest

- (void)setUp {
  [super setUp];

  self.delegate = [[OBHopDisplayMetricSegmentedControlDelegate alloc] initWithSettings:self.settings];
}

- (void)testSegmentTitles
{
  XCTAssertEqualObjects((@[ @"Weight", @"IBUs" ]), [self.delegate segmentTitlesForSegmentedControl:nil]);
}

- (void)testSegmentSelected
{
  self.settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricIbu);

  [self.delegate segmentedControl:nil segmentSelected:0];
  XCTAssertEqualObjects(@(OBHopAdditionMetricWeight), self.settings.hopAdditionDisplayMetric);

  [self.delegate segmentedControl:nil segmentSelected:1];
  XCTAssertEqualObjects(@(OBHopAdditionMetricIbu), self.settings.hopAdditionDisplayMetric);
}

- (void)testInitiallySelectedSegment
{
  self.settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricIbu);
  XCTAssertEqual(1, [self.delegate initiallySelectedSegmentForSegmentedControl:nil]);

  self.settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricWeight);
  XCTAssertEqual(0, [self.delegate initiallySelectedSegmentForSegmentedControl:nil]);
}

@end
