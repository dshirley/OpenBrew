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
#import "OBGaugeViewController.h"
#import "OBGaugePageViewControllerDataSource.h"

// TODO: It isn't necessary to use the OBBaseTestCase here, remove it
@interface OBGaugePageViewControllerDataSourceTest : OBBaseTestCase
@property (nonatomic) OBGaugePageViewController *pageViewController;
@end

@implementation OBGaugePageViewControllerDataSourceTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.pageViewController = [storyboard instantiateViewControllerWithIdentifier:@"maltGauge"];
}

- (void)testInitWithRecipeDisplayMetrics
{
  NSArray *metrics = @[];
  OBGaugePageViewControllerDataSource *dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithRecipe:self.recipe displayMetrics:metrics];

  XCTAssertEqual(self.recipe, dataSource.recipe);
  XCTAssertEqual(metrics, dataSource.metrics);
}

- (void)testViewControllerAtIndex_emptyMetrics
{
  OBGaugePageViewControllerDataSource *dataSource = nil;

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithRecipe:self.recipe displayMetrics:@[]];
  XCTAssertThrows([dataSource pageViewController:nil viewControllerAtIndex:0]);
}

- (void)testViewControllerAtIndex
{
  OBGaugePageViewControllerDataSource *dataSource = nil;
  OBGaugeViewController *vc = nil;
  NSArray *metrics = @[ @(OBMetricOriginalGravity), @(OBMetricAbv) ];

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithRecipe:self.recipe displayMetrics:metrics];

  vc = [dataSource pageViewController:self.pageViewController viewControllerAtIndex:0];
  XCTAssertNotNil(vc);
  XCTAssertNotNil(vc.valueLabel);
  XCTAssertNotNil(vc.descriptionLabel);
  XCTAssertNotNil(vc.colorView);
  XCTAssertEqual(OBMetricOriginalGravity, vc.metricToDisplay);
  XCTAssertEqual(self.recipe, vc.recipe);

  XCTAssertEqualObjects(@"1.000", vc.valueLabel.text);
  XCTAssertEqualObjects(@"Original gravity", vc.descriptionLabel.text);

  vc = [dataSource pageViewController:self.pageViewController viewControllerAtIndex:1];
  XCTAssertNotNil(vc);
  XCTAssertNotNil(vc.valueLabel);
  XCTAssertNotNil(vc.descriptionLabel);
  XCTAssertNotNil(vc.colorView);
  XCTAssertEqual(OBMetricAbv, vc.metricToDisplay);
  XCTAssertEqual(self.recipe, vc.recipe);

  XCTAssertEqualObjects(@"0.0", vc.valueLabel.text);
  XCTAssertEqualObjects(@"ABV", vc.descriptionLabel.text);
}

- (void)testViewControllerBeforeViewController
{
  OBGaugePageViewControllerDataSource *dataSource = nil;
  OBGaugeViewController *vc = [[OBGaugeViewController alloc] init];
  OBGaugeViewController *returnedVc = nil;
  NSArray *metrics = @[ @(OBMetricOriginalGravity), @(OBMetricAbv), @(OBMetricIbu) ];

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithRecipe:self.recipe displayMetrics:metrics];

  vc.metricToDisplay = OBMetricOriginalGravity;
  returnedVc = (id)[dataSource pageViewController:self.pageViewController viewControllerBeforeViewController:vc];
  XCTAssertNil(returnedVc);

  vc.metricToDisplay = OBMetricAbv;
  returnedVc = (id)[dataSource pageViewController:self.pageViewController viewControllerBeforeViewController:vc];
  XCTAssertNotNil(returnedVc);
  XCTAssertEqual(OBMetricOriginalGravity, returnedVc.metricToDisplay);
  XCTAssertEqual(self.recipe, returnedVc.recipe);

  vc.metricToDisplay = OBMetricIbu;
  returnedVc = (id)[dataSource pageViewController:self.pageViewController viewControllerBeforeViewController:vc];
  XCTAssertNotNil(returnedVc);
  XCTAssertEqual(OBMetricAbv, returnedVc.metricToDisplay);
  XCTAssertEqual(self.recipe, returnedVc.recipe);

  vc.metricToDisplay = OBMetricFinalGravity;
  XCTAssertThrows([dataSource pageViewController:self.pageViewController viewControllerBeforeViewController:vc]);
}

- (void)testViewControllerAfterViewController
{
  OBGaugePageViewControllerDataSource *dataSource = nil;
  OBGaugeViewController *vc = [[OBGaugeViewController alloc] init];
  OBGaugeViewController *returnedVc = nil;
  NSArray *metrics = @[ @(OBMetricOriginalGravity), @(OBMetricAbv), @(OBMetricIbu) ];

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithRecipe:self.recipe displayMetrics:metrics];

  vc.metricToDisplay = OBMetricOriginalGravity;
  returnedVc = (id)[dataSource pageViewController:self.pageViewController viewControllerAfterViewController:vc];

  XCTAssertNotNil(returnedVc);
  XCTAssertEqual(OBMetricAbv, returnedVc.metricToDisplay);
  XCTAssertEqual(self.recipe, returnedVc.recipe);

  vc.metricToDisplay = OBMetricAbv;
  returnedVc = (id)[dataSource pageViewController:self.pageViewController viewControllerAfterViewController:vc];
  XCTAssertNotNil(returnedVc);
  XCTAssertEqual(OBMetricIbu, returnedVc.metricToDisplay);
  XCTAssertEqual(self.recipe, returnedVc.recipe);

  vc.metricToDisplay = OBMetricIbu;
  returnedVc = (id)[dataSource pageViewController:self.pageViewController viewControllerAfterViewController:vc];
  XCTAssertNil(returnedVc);

  vc.metricToDisplay = OBMetricFinalGravity;
  XCTAssertThrows([dataSource pageViewController:self.pageViewController viewControllerAfterViewController:vc]);
}

- (void)testPresentationCountForPageViewController
{
  OBGaugePageViewControllerDataSource *dataSource = nil;
  NSArray *metrics = @[ @(OBMetricOriginalGravity), @(OBMetricAbv), @(OBMetricIbu) ];

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithRecipe:self.recipe displayMetrics:metrics];

  XCTAssertEqual(metrics.count, [dataSource presentationCountForPageViewController:nil]);
  XCTAssertEqual(metrics.count, [dataSource presentationCountForPageViewController:(id)@"doesn't matter"]);

  metrics = @[];
  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithRecipe:self.recipe displayMetrics:metrics];

  XCTAssertEqual(metrics.count, [dataSource presentationCountForPageViewController:nil]);
  XCTAssertEqual(metrics.count, [dataSource presentationCountForPageViewController:(id)@"doesn't matter"]);
}

- (void)testPresentationIndexForPageViewController
{
  OBGaugePageViewControllerDataSource *dataSource = nil;

  dataSource = [[OBGaugePageViewControllerDataSource alloc] initWithRecipe:self.recipe displayMetrics:@[]];

  XCTAssertEqual(0, [dataSource presentationIndexForPageViewController:nil]);
  XCTAssertEqual(0, [dataSource presentationIndexForPageViewController:(id)@"doesn't matter"]);
}

@end
