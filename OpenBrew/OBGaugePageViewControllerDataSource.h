//
//  OBGaugePageViewControllerDataSource.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/18/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBGaugePageViewControllerDataSource : NSObject <UIPageViewControllerDataSource>

@property (nonatomic, readonly) NSArray *viewControllers;

- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

#pragma mark UIPageViewControllerDataSource methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController;

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController;

@end
