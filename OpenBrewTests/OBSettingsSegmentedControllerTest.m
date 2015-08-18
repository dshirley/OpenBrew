//
//  OBSegmentedControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/1/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OBBaseTestCase.h"
#import "OBSegmentedController.h"
#import "OBKvoUtils.h"

@interface OBSegmentedController(Testing)

- (void)segmentChanged:(UISegmentedControl *)sender;
- (NSArray *)segmentActions;

@end

@interface OBSegmentedControllerTest : OBBaseTestCase

@end

@implementation OBSegmentedControllerTest

- (void)testInit
{
  UISegmentedControl *s = [[UISegmentedControl alloc] initWithItems:@[ @"these", @"will", @"be", @"removed"]];
  OBSegmentedController *ctrl = [[OBSegmentedController alloc] initWithSegmentedControl:s
                                                                                  googleAnalyticsAction:@"test"];

  id mockCtrl = [OCMockObject partialMockForObject:ctrl];
  [[mockCtrl expect] segmentChanged:s];

  XCTAssertEqual(ctrl.segmentedControl, s);
  XCTAssertEqual(0, ctrl.segmentedControl.numberOfSegments);

  [s sendActionsForControlEvents:UIControlEventValueChanged];

  [mockCtrl verify];
}

- (void)testAddSegment
{
  UISegmentedControl *s = [[UISegmentedControl alloc] initWithItems:@[ @"these", @"will", @"be", @"removed"]];
  OBSegmentedController *ctrl = [[OBSegmentedController alloc] initWithSegmentedControl:s
                                                                                  googleAnalyticsAction:@"test"];

  OBSegmentSelectedAction block1 = ^(void) {};
  OBSegmentSelectedAction block2 = ^(void) {};
  OBSegmentSelectedAction block3 = ^(void) {};

  XCTAssertEqual(0, s.numberOfSegments);
  [ctrl addSegment:@"first" actionWhenSelected:block1];

  XCTAssertEqual(1, s.numberOfSegments);
  XCTAssertEqual(@"first", [s titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@[ block1 ], [ctrl segmentActions]);

  [ctrl addSegment:@"second" actionWhenSelected:block2];
  XCTAssertEqual(2, s.numberOfSegments);
  XCTAssertEqual(@"first", [s titleForSegmentAtIndex:0]);
  XCTAssertEqual(@"second", [s titleForSegmentAtIndex:1]);
  XCTAssertEqualObjects((@[ block1, block2 ]), [ctrl segmentActions]);

  [ctrl addSegment:@"third" actionWhenSelected:block3];
  XCTAssertEqual(3, s.numberOfSegments);
  XCTAssertEqual(@"first", [s titleForSegmentAtIndex:0]);
  XCTAssertEqual(@"second", [s titleForSegmentAtIndex:1]);
  XCTAssertEqual(@"third", [s titleForSegmentAtIndex:2]);
  XCTAssertEqualObjects((@[ block1, block2, block3 ]), [ctrl segmentActions]);
}

- (void)testSegmentSelection
{
  UISegmentedControl *s = [[UISegmentedControl alloc] initWithFrame:CGRectZero];

  OBBrewery *brewery = self.brewery;

  OBSegmentedController *ctrl =
    [[OBSegmentedController alloc] initWithSegmentedControl:s
                                              googleAnalyticsAction:@"test"];

  [ctrl addSegment:@"OG" actionWhenSelected:^(void) {
    brewery.maltAdditionDisplayMetric = @(OBMetricOriginalGravity);
  }];

  [ctrl addSegment:@"FG" actionWhenSelected:^(void) {
    brewery.maltAdditionDisplayMetric = @(OBMetricFinalGravity);
  }];

  [ctrl addSegment:@"IBU" actionWhenSelected:^(void) {
    brewery.maltAdditionDisplayMetric = @(OBMetricIbu);
  }];

  // Select IBU
  [s setSelectedSegmentIndex:2];
  self.brewery.maltAdditionDisplayMetric = @(-1);
  [s sendActionsForControlEvents:UIControlEventValueChanged];
  XCTAssertEqualObjects(@(OBMetricIbu), self.brewery.maltAdditionDisplayMetric);

  [s setSelectedSegmentIndex:0];
  [s sendActionsForControlEvents:UIControlEventValueChanged];
  XCTAssertEqualObjects(@(OBMetricOriginalGravity), self.brewery.maltAdditionDisplayMetric);
}


@end
