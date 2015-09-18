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


@implementation OBGaugePageViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  UIPageControl *pageControl = [UIPageControl appearance];
  pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
  pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
  pageControl.backgroundColor = [UIColor whiteColor];
}

- (void)setDataSource:(OBGaugePageViewControllerDataSource *)dataSource;
{
  [super setDataSource:dataSource];

  NSMutableArray *viewControllers = [NSMutableArray array];

  if (dataSource.metrics.count > 0) {
    [viewControllers addObject:[dataSource pageViewController:self viewControllerAtIndex:0]];

    [self setViewControllers:viewControllers
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
  }
}

@end
