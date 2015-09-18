//
//  OBGaugePageViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSettings.h"

@class OBRecipe;

@interface OBGaugePageViewController : UIPageViewController <UIPageViewControllerDataSource>

@property (nonatomic) OBRecipe *recipe;

- (void)addGaugeMetrics:(NSArray *)gaugeMetrics;

- (void)refresh;

#pragma mark UIPageViewControllerDataSource methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController;

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController;

@end
