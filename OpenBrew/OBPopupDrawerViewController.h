//
//  OBPopupDrawerViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 11/30/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBPopupDrawerViewController : UIViewController

@property (nonatomic, readonly) UIViewController *viewController;

- (instancetype)initWithViewController:(UIViewController *)viewController;

- (void)showAnimate;

- (void)removeAnimate;

@end

