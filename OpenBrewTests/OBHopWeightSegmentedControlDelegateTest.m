//
//  OBHopWeightSegmentedControlDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBHopWeightSegmentedControlDelegate.h"
#import "OBSettings.h"
#import "OBBaseTestCase.h"

@interface OBHopWeightSegmentedControlDelegateTest : OBBaseTestCase
@property (nonatomic) OBHopWeightSegmentedControlDelegate *delegate;
@end

@implementation OBHopWeightSegmentedControlDelegateTest

- (void)setUp {
  [super setUp];

  self.delegate = [[OBHopWeightSegmentedControlDelegate alloc] initWithSettings:self.settings];
}

- (void)testSegmentTitles
{
  XCTAssertEqualObjects((@[ @"Ounces", @"Grams" ]), [self.delegate segmentTitlesForSegmentedControl:nil]);
}

- (void)testSegmentSelected
{
  self.settings.hopQuantityUnits = @(OBHopQuantityUnitsMetric);

  [self.delegate segmentedControl:nil segmentSelected:0];
  XCTAssertEqualObjects(@(OBHopQuantityUnitsImperial), self.settings.hopQuantityUnits);

  [self.delegate segmentedControl:nil segmentSelected:1];
  XCTAssertEqualObjects(@(OBHopQuantityUnitsMetric), self.settings.hopQuantityUnits);
}

- (void)testInitiallySelectedSegment
{
  self.settings.hopQuantityUnits = @(OBHopQuantityUnitsMetric);
  XCTAssertEqual(1, [self.delegate initiallySelectedSegmentForSegmentedControl:nil]);

  self.settings.hopQuantityUnits = @(OBHopQuantityUnitsImperial);
  XCTAssertEqual(0, [self.delegate initiallySelectedSegmentForSegmentedControl:nil]);
}

@end
