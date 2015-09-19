//
//  OBGaugePageViewControllerDataSource.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/18/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBRecipe, OBGaugeViewController;

@interface OBGaugePageViewControllerDataSource : NSObject <UIPageViewControllerDataSource>

@property (nonatomic, readonly) OBRecipe *recipe;
@property (nonatomic, readonly) NSArray *metrics;

- (instancetype)initWithRecipe:(OBRecipe *)recipe displayMetrics:(NSArray *)metrics;

- (OBGaugeViewController *)pageViewController:(UIPageViewController *)pageViewController
                        viewControllerAtIndex:(NSInteger)index;

#pragma mark UIPageViewControllerDataSource methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController;

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController;

@end
