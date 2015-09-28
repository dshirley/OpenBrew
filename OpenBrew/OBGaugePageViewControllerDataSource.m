//
//  OBGaugePageViewControllerDataSource.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/18/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBGaugePageViewControllerDataSource.h"
#import "OBGaugeViewController.h"

@interface OBGaugePageViewControllerDataSource ()
@property (nonatomic) OBRecipe *recipe;
@property (nonatomic) OBSettings *settings;
@property (nonatomic) NSArray *metrics;
@end

@implementation OBGaugePageViewControllerDataSource

- (instancetype)initWithRecipe:(OBRecipe *)recipe settings:(OBSettings *)settings displayMetrics:(NSArray *)metrics;
{
  self = [super init];

  if (self) {
    self.recipe = recipe;
    self.settings = settings;
    self.metrics = metrics;
  }

  return self;
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

  return [self pageViewController:pageViewController viewControllerAtIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
  OBGaugeViewController *gaugeViewController = (OBGaugeViewController *)viewController;

  NSInteger index = [self.metrics indexOfObject:@(gaugeViewController.metricToDisplay)];
  NSAssert(index != NSNotFound, @"Metric not found: %@", @(gaugeViewController.metricToDisplay));

  if (index < 0 || index >= (self.metrics.count - 1)) {
    return nil;
  }

  return [self pageViewController:pageViewController viewControllerAtIndex:(index + 1)];
}

- (OBGaugeViewController *)pageViewController:(UIPageViewController *)pageViewController
                        viewControllerAtIndex:(NSInteger)index
{
  OBGaugeMetric metric = [self.metrics[index] integerValue];

  OBGaugeViewController *gaugeViewController = [pageViewController.storyboard instantiateViewControllerWithIdentifier:@"gaugeViewController"];

  (void)gaugeViewController.view;

  gaugeViewController.metricToDisplay = metric;
  gaugeViewController.recipe = self.recipe;
  gaugeViewController.settings = self.settings;
  [gaugeViewController refresh];

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
