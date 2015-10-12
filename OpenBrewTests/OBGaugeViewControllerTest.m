//
//  OBGaugeViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/19/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBNumericGaugeViewController.h"
#import <OCMock/OCMock.h>
#import "OBMaltAddition.h"
#import "OBHopAddition.h"
#import "OBColorView.h"

@interface OBNumericGaugeViewController(Private)
@property (nonatomic) IBOutlet UICountingLabel *valueLabel;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@interface OBNumericGaugeViewControllerTest : XCTestCase
@property (nonatomic) float testProperty;
@end

@implementation OBNumericGaugeViewControllerTest

- (void)testInit
{
  OBNumericGaugeViewController *vc = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                             keyToDisplay:@"testProperty"
                                                                              valueFormat:@"test format"
                                                                          descriptionText:@"description text"];

  XCTAssertEqual(self, vc.target);
  XCTAssertEqualObjects(@"testProperty", vc.key);
  XCTAssertEqualObjects(@"test format", vc.valueFormat);
  XCTAssertEqualObjects(@"description text", vc.descriptionText);

  // Make sure key value observing is setup
  id mockVc = [OCMockObject partialMockForObject:vc];
  [[mockVc expect] refresh:YES];

  self.testProperty = 42;

  [mockVc verify];
}

// All IBOutlets should be populated
- (void)testLoadView
{
  OBNumericGaugeViewController *vc = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                             keyToDisplay:@"testProperty"
                                                                              valueFormat:@"test format"
                                                                          descriptionText:@"description text"];

  id mockVc = [OCMockObject partialMockForObject:vc];
  [[mockVc expect] refresh:NO];

  (void)vc.view;

  XCTAssertEqual(UICountingLabel.class, vc.valueLabel.class);
  XCTAssertEqual(UILabel.class, vc.descriptionLabel.class);

  [mockVc verify];
}

- (void)testRefresh
{
  self.testProperty = 12.3456;

  OBNumericGaugeViewController *vc = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                             keyToDisplay:@"testProperty"
                                                                              valueFormat:@"%.3f"
                                                                          descriptionText:@"description text"];

  // Setup the labels. This also calls refresh
  (void)vc.view;

  XCTAssertEqualObjects(@"12.346", vc.valueLabel.text, @"rounds the value up");
  XCTAssertEqualObjects(@"description text", vc.descriptionLabel.text);
}

@end
