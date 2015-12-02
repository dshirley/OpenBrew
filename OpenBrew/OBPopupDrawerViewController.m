//
//  OBPopupDrawerViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 11/30/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBPopupDrawerViewController.h"

#define ANIMATE_DURATION 0.25

@interface OBPopupDrawerViewController ()
@property (nonatomic) UIBarButtonItem *origRightBarButton;
@property (nonatomic) UIViewController *viewController;
@property (nonatomic, assign) CGFloat drawerHeight;
@end

@implementation OBPopupDrawerViewController

- (instancetype)initWithViewController:(UIViewController *)viewController
{
  self = [super initWithNibName:@"OBPopupDrawerViewController"
                         bundle:[NSBundle mainBundle]];

  if (self) {
    self.viewController = viewController;
    self.drawerHeight = viewController.view.frame.size.height;
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.view.hidden = YES;

  // Add the child view controller
  [self addChildViewController:self.viewController];
  [self.view addSubview:self.viewController.view];
  [self.viewController didMoveToParentViewController:self];
}

- (void)showAnimate
{
  self.viewController.view.frame = CGRectMake(0, self.view.frame.size.height,
                                              self.view.frame.size.width, self.drawerHeight);

  self.view.backgroundColor = [UIColor clearColor];
  self.view.hidden = NO;

  // removeAnimate will add the navigation items back
  UINavigationItem *navigationItem = self.parentViewController.navigationItem;
  [navigationItem setHidesBackButton:YES animated:YES];
  self.origRightBarButton = navigationItem.rightBarButtonItem;
  navigationItem.rightBarButtonItem = nil;

  [UIView animateWithDuration:ANIMATE_DURATION
                        delay:0.0
                      options:0
                   animations:^{
                     self.viewController.view.frame = CGRectOffset(self.viewController.view.frame, 0, -self.drawerHeight);
                     self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
                   }
                   completion:^(BOOL finished) {
                     navigationItem.rightBarButtonItem =
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(removeAnimate)];
                   }];
}

- (void)removeAnimate
{
  UINavigationItem *navigationItem = self.parentViewController.navigationItem;
  navigationItem.rightBarButtonItem = nil;

  [UIView animateWithDuration:ANIMATE_DURATION
                        delay:0.0
                      options:0
                   animations:^{

                     self.viewController.view.frame = CGRectOffset(self.viewController.view.frame,
                                                                   0, self.drawerHeight);

                     self.view.backgroundColor = [UIColor clearColor];
                   }
                   completion:^(BOOL finished) {
                     self.view.hidden = YES;
                     navigationItem.hidesBackButton = NO;
                     navigationItem.rightBarButtonItem = self.origRightBarButton;
                   }];
}

- (IBAction)greyoutButtonTouchDown:(id)sender
{
  [self removeAnimate];
}

@end
