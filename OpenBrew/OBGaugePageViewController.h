//
//  OBGaugePageViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBGaugePageViewControllerDataSource.h"

@interface OBGaugePageViewController : UIPageViewController

- (void)setDataSource:(OBGaugePageViewControllerDataSource *)dataSource;

@end
