//
//  OBGaugePageViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBGaugePageViewController.h"
#import "OBNumericGaugeViewController.h"
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

  if (dataSource.viewControllers.count > 0) {

    [self setViewControllers:@[ dataSource.viewControllers[0] ]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
  }
}

@end
