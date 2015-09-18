//
//  OBGaugePageViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBGaugePageViewController.h"
#import "OBGaugeViewController.h"
#import "OBRecipe.h"

@interface OBGaugePageViewController ()
@property (nonatomic) NSMutableArray *metrics;
@end

@implementation OBGaugePageViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.metrics = [NSMutableArray array];
  self.dataSource = self;

  UIPageControl *pageControl = [UIPageControl appearance];
  pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
  pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
  pageControl.backgroundColor = [UIColor whiteColor];
}

- (void)addGaugeMetrics:(NSArray *)gaugeMetrics
{
  self.metrics = [NSMutableArray arrayWithArray:gaugeMetrics];

  NSMutableArray *viewControllers = [NSMutableArray array];

  if (self.metrics.count > 0) {
    [viewControllers addObject:[self viewControllerAtIndex:0]];
  }

  [self setViewControllers:viewControllers
                 direction:UIPageViewControllerNavigationDirectionForward
                  animated:NO
                completion:nil];
}

- (void)refresh
{
  for (OBGaugeViewController *vc in self.viewControllers) {
    [vc refresh];
  }
}

#pragma mark UIPageViewControllerDataSource methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
  OBGaugeViewController *gaugeViewController = (OBGaugeViewController *)viewController;

  NSInteger index = [self.metrics indexOfObject:@(gaugeViewController.metricToDisplay)];
  NSAssert(index != NSNotFound, @"Metric not found: %@", @(gaugeViewController.metricToDisplay));

  if (index <= 0) {
    return nil;
  }

  return [self viewControllerAtIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
  OBGaugeViewController *gaugeViewController = (OBGaugeViewController *)viewController;

  NSInteger index = [self.metrics indexOfObject:@(gaugeViewController.metricToDisplay)];
  NSAssert(index != NSNotFound, @"Metric not found: %@", @(gaugeViewController.metricToDisplay));

  if (index < 0 || index >= (self.metrics.count - 1)) {
    return nil;
  }

  return [self viewControllerAtIndex:(index + 1)];
}

- (OBGaugeViewController *)viewControllerAtIndex:(NSInteger)index
{
  OBGaugeMetric metric = [self.metrics[index] integerValue];

  OBGaugeViewController *gaugeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"gaugeViewController"];
  [gaugeViewController loadViewIfNeeded];

  gaugeViewController.metricToDisplay = metric;
  gaugeViewController.recipe = self.recipe;

  return gaugeViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
  return self.metrics.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
  return 0;
}

@end
