//
//  OBSettingsSegmentedControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/1/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OBBaseTestCase.h"
#import "OBSettingsSegmentedController.h"
#import "OBKvoUtils.h"

@interface OBSettingsSegmentedController(Testing)

- (void)segmentChanged:(UISegmentedControl *)sender;
- (NSArray *)valueMapping;

@end

@interface OBSettingsSegmentedControllerTest : OBBaseTestCase

@end

@implementation OBSettingsSegmentedControllerTest

- (void)testInit
{
  UISegmentedControl *s = [[UISegmentedControl alloc] initWithItems:@[ @"these", @"will", @"be", @"removed"]];
  OBSettingsSegmentedController *ctrl = [[OBSettingsSegmentedController alloc] initWithSegmentedControl:s
                                                                                                brewery:self.brewery
                                                                                             settingKey:@"fake"];

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
  OBSettingsSegmentedController *ctrl = [[OBSettingsSegmentedController alloc] initWithSegmentedControl:s
                                                                                                brewery:self.brewery
                                                                                             settingKey:@"fake"];

  XCTAssertEqual(0, s.numberOfSegments);
  [ctrl addSegment:@"first" setsValue:@(100)];

  XCTAssertEqual(1, s.numberOfSegments);
  XCTAssertEqual(@"first", [s titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@[ @(100)], [ctrl valueMapping]);

  [ctrl addSegment:@"second" setsValue:@(200)];
  XCTAssertEqual(2, s.numberOfSegments);
  XCTAssertEqual(@"first", [s titleForSegmentAtIndex:0]);
  XCTAssertEqual(@"second", [s titleForSegmentAtIndex:1]);
  XCTAssertEqualObjects((@[ @(100), @(200)]), [ctrl valueMapping]);

  [ctrl addSegment:@"third" setsValue:@"asdf"];
  XCTAssertEqual(3, s.numberOfSegments);
  XCTAssertEqual(@"first", [s titleForSegmentAtIndex:0]);
  XCTAssertEqual(@"second", [s titleForSegmentAtIndex:1]);
  XCTAssertEqual(@"third", [s titleForSegmentAtIndex:2]);
  XCTAssertEqualObjects((@[ @(100), @(200), @"asdf"]), [ctrl valueMapping]);
}

- (void)testUpdateSelectedSegment
{
  UISegmentedControl *s = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
  OBSettingsSegmentedController *ctrl =
    [[OBSettingsSegmentedController alloc] initWithSegmentedControl:s
                                                            brewery:self.brewery
                                                         settingKey:KVO_KEY(maltAdditionDisplayMetric)];

  [ctrl addSegment:@"OG" setsValue:@(OBMetricOriginalGravity)];
  [ctrl addSegment:@"FG" setsValue:@(OBMetricFinalGravity)];
  [ctrl addSegment:@"IBU" setsValue:@(OBMetricIbu)];

  self.brewery.maltAdditionDisplayMetric = @(OBMetricIbu);
  [ctrl updateSelectedSegment];
  XCTAssertEqual(2, [s selectedSegmentIndex]);
  XCTAssertEqualObjects(@(OBMetricIbu), self.brewery.maltAdditionDisplayMetric);

  self.brewery.maltAdditionDisplayMetric = @(OBMetricFinalGravity);
  [ctrl updateSelectedSegment];
  XCTAssertEqual(1, [s selectedSegmentIndex]);
  XCTAssertEqualObjects(@(OBMetricFinalGravity), self.brewery.maltAdditionDisplayMetric);

  self.brewery.maltAdditionDisplayMetric = nil;
  [ctrl updateSelectedSegment];
  XCTAssertEqual(0, [s selectedSegmentIndex]);
  XCTAssertEqualObjects(@(OBMetricOriginalGravity), self.brewery.maltAdditionDisplayMetric);
}

- (void)testUpdateSelectedSegment_noSegments
{
  UISegmentedControl *s = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
  OBSettingsSegmentedController *ctrl =
  [[OBSettingsSegmentedController alloc] initWithSegmentedControl:s
                                                          brewery:self.brewery
                                                       settingKey:KVO_KEY(maltAdditionDisplayMetric)];

  [ctrl updateSelectedSegment];

  XCTAssertEqual(UISegmentedControlNoSegment, [s selectedSegmentIndex]);
  XCTAssertEqual(0, [s numberOfSegments]);
}

- (void)testUpdateSelectedSegment_invalidKey
{
  UISegmentedControl *s = [[UISegmentedControl alloc] initWithItems:@[ @"these", @"will", @"be", @"removed"]];
  OBSettingsSegmentedController *ctrl = [[OBSettingsSegmentedController alloc] initWithSegmentedControl:s
                                                                                                brewery:self.brewery
                                                                                             settingKey:@"fake"];

  [ctrl addSegment:@"segment" setsValue:@(100)];
  XCTAssertThrows([ctrl updateSelectedSegment]);
}

- (void)testSegmentSelection
{
  UISegmentedControl *s = [[UISegmentedControl alloc] initWithFrame:CGRectZero];
  OBSettingsSegmentedController *ctrl =
    [[OBSettingsSegmentedController alloc] initWithSegmentedControl:s
                                                            brewery:self.brewery
                                                         settingKey:KVO_KEY(maltAdditionDisplayMetric)];

  [ctrl addSegment:@"OG" setsValue:@(OBMetricOriginalGravity)];
  [ctrl addSegment:@"FG" setsValue:@(OBMetricFinalGravity)];
  [ctrl addSegment:@"IBU" setsValue:@(OBMetricIbu)];


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
