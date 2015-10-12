//
//  OBGaugePageViewControllerDataSourceTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/18/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBGaugePageViewController.h"
#import "OBNumericGaugeViewController.h"
#import "OBGaugePageViewControllerDataSource.h"

// TODO: It isn't necessary to use the OBBaseTestCase here, remove it
@interface OBGaugePageViewControllerDataSourceTest : XCTestCase
@property (nonatomic) OBGaugePageViewController *pageViewController;
@end

@implementation OBGaugePageViewControllerDataSourceTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.pageViewController = [storyboard instantiateViewControllerWithIdentifier:@"maltGauge"];
}

- (void)testInitWithViewControllers
{
  NSArray *viewControllers = @[];
  OBGaugePageViewControllerDataSource *dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:viewControllers];

  XCTAssertEqual(viewControllers, dataSource.viewControllers);
}

- (void)testViewControllerBeforeViewController
{
  OBGaugePageViewControllerDataSource *dataSource = nil;
  NSArray *viewControllers = @[ @"fake vc 1", @"fake vc 2" ];

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:viewControllers];

  XCTAssertNil([dataSource pageViewController:self.pageViewController viewControllerBeforeViewController:viewControllers[0]]);
  XCTAssertEqual(viewControllers[0], [dataSource pageViewController:nil viewControllerBeforeViewController:viewControllers[1]]);

  XCTAssertThrows([dataSource pageViewController:nil viewControllerBeforeViewController:((id)@"bad vc")]);
}

- (void)testViewControllerAfterViewController
{
  OBGaugePageViewControllerDataSource *dataSource = nil;

  NSArray *viewControllers = @[ @"fake vc 1", @"fake vc 2" ];

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:viewControllers];

  XCTAssertNil([dataSource pageViewController:nil viewControllerAfterViewController:viewControllers[1]]);
  XCTAssertEqual(viewControllers[1], [dataSource pageViewController:nil viewControllerAfterViewController:viewControllers[0]]);
  XCTAssertThrows([dataSource pageViewController:nil viewControllerAfterViewController:((id)@"bad vc")]);
}

- (void)testPresentationCountForPageViewController
{
  OBGaugePageViewControllerDataSource *dataSource = nil;

  NSArray *viewControllers = @[ @"fake vc 1", @"fake vc 2" ];

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:viewControllers];

  XCTAssertEqual(2, [dataSource presentationCountForPageViewController:nil]);
  XCTAssertEqual(2, [dataSource presentationCountForPageViewController:(id)@"doesn't matter"]);

  viewControllers = @[];
  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:viewControllers];

  XCTAssertEqual(0, [dataSource presentationCountForPageViewController:nil]);
  XCTAssertEqual(0, [dataSource presentationCountForPageViewController:(id)@"doesn't matter"]);
}

- (void)testPresentationIndexForPageViewController
{
  OBGaugePageViewControllerDataSource *dataSource = nil;

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:@[]];

  XCTAssertEqual(0, [dataSource presentationIndexForPageViewController:nil]);
  XCTAssertEqual(0, [dataSource presentationIndexForPageViewController:(id)@"doesn't matter"]);
}

@end
