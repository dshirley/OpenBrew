//
//  OBGaugePageViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/18/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBGaugePageViewController.h"
#import <OCMock/OCMock.h>
#import "OBGaugePageViewControllerDataSource.h"
#import "OBGaugeViewController.h"

@interface OBGaugePageViewControllerTest : XCTestCase
@end

@implementation OBGaugePageViewControllerTest

- (void)testViewDidLoad
{
  OBGaugePageViewController *vc = [[OBGaugePageViewController alloc] init];

  [vc viewDidLoad];

  XCTAssertEqual([UIColor lightGrayColor], [[UIPageControl appearance] pageIndicatorTintColor]);
  XCTAssertEqual([UIColor blackColor], [[UIPageControl appearance] currentPageIndicatorTintColor]);
  XCTAssertEqual([UIColor whiteColor], [[UIPageControl appearance] backgroundColor]);
}

- (void)testSetDataSource_nil
{
  OBGaugePageViewController *vc = [[OBGaugePageViewController alloc] init];

  id mockVc = [OCMockObject partialMockForObject:vc];
  [[mockVc reject] setViewControllers:OCMOCK_ANY
                            direction:UIPageViewControllerNavigationDirectionForward
                             animated:NO
                           completion:OCMOCK_ANY];

  [vc setDataSource:nil];

  [mockVc verify];
}

- (void)testSetDataSource
{
  OBGaugePageViewController *vc = [[OBGaugePageViewController alloc] init];

  id mockVc = [OCMockObject partialMockForObject:vc];
  id mockDataSource = [OCMockObject mockForClass:OBGaugePageViewControllerDataSource.class];

  [[mockVc expect] setViewControllers:OCMOCK_ANY
                            direction:UIPageViewControllerNavigationDirectionForward
                             animated:NO
                           completion:nil];

  OBGaugePageViewController *gaugeViewController = [[OBGaugePageViewController alloc] init];
  [[[mockDataSource stub] andReturn:@[ gaugeViewController ]] metrics];
  [[[mockDataSource stub] andReturn:gaugeViewController] pageViewController:vc viewControllerAtIndex:0];

  [vc setDataSource:mockDataSource];

  [mockVc verify];
  [mockDataSource verify];

  XCTAssertEqual(mockDataSource, vc.dataSource);
}

@end
