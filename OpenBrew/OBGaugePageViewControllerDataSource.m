//
//  OBGaugePageViewControllerDataSource.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/18/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBGaugePageViewControllerDataSource.h"
#import "OBNumericGaugeViewController.h"

@interface OBGaugePageViewControllerDataSource ()
@property (nonatomic) NSArray *viewControllers;
@end

@implementation OBGaugePageViewControllerDataSource

- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
  self = [super init];

  if (self) {
    self.viewControllers = viewControllers;
  }

  return self;
}

#pragma mark UIPageViewControllerDataSource methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
  NSInteger index = [self.viewControllers indexOfObject:viewController];
  NSAssert(index != NSNotFound, @"View controller not found");

  if (index <= 0) {
    return nil;
  }

  return self.viewControllers[index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
  NSInteger index = [self.viewControllers indexOfObject:viewController];
  NSAssert(index != NSNotFound, @"View controller not found");

  if (index < 0 || index >= (self.viewControllers.count - 1)) {
    return nil;
  }

  return self.viewControllers[index + 1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
  return self.viewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
  return 0;
}

@end
