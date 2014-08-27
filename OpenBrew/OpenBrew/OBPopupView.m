//
//  OBPopupView.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/27/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBPopupView.h"

@interface OBPopupView()

@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BOOL contentIsVisible;
@property (nonatomic, assign) CGRect parentFrame;
@property (nonatomic, assign) CGRect contentHiddenFrame;
@property (nonatomic, assign) CGRect contentVisibleFrame;

@property (nonatomic, strong) UINavigationItem *navigationItem;
@property (nonatomic, strong) UIBarButtonItem *savedRightBarButton;
@property (nonatomic, strong) UIBarButtonItem *displaySettingsDoneButton;

@end

@implementation OBPopupView

- (id)initWithFrame:(CGRect)frame
     andContentView:(UIView *)view
  andNavigationItem:(UINavigationItem *)navItem
{
    self = [super initWithFrame:CGRectZero];

    if (self) {
      _parentFrame = frame;
      _contentIsVisible = NO;
      _contentView = view;

      _navigationItem = navItem;
      _displaySettingsDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(dismissContent)];

      _dismissButton = [[UIButton alloc] initWithFrame:frame];
      _dismissButton.backgroundColor = [UIColor blackColor];
      _dismissButton.alpha = 0.25;
      [_dismissButton addTarget:self
                         action:@selector(dismissContent)
               forControlEvents:UIControlEventTouchUpInside];

      _contentHiddenFrame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height,
                                       frame.size.width, _contentView.frame.size.height);

      _contentVisibleFrame = CGRectOffset(_contentHiddenFrame,
                                          0, -_contentView.frame.size.height);

      _contentView.frame = _contentHiddenFrame;
    }

    return self;
}

- (void)popupContent
{
  if (self.contentIsVisible) {
    return;
  }

  // In an ideal world, this navbar modification logic would go in a delegate
  // class.  We're mixing up the controller and view logic a bit.  However,
  // in this case, it makes the code a bit more simple, and it has little impact
  // on maintainability. If this becomes a problem, a delegate can always be
  // created.
  [self.navigationItem setHidesBackButton:YES animated:YES];
  self.savedRightBarButton = self.navigationItem.rightBarButtonItem;
  [self.navigationItem setRightBarButtonItem:self.displaySettingsDoneButton animated:YES];

  self.frame = self.parentFrame;

  [self addSubview:self.dismissButton];
  [self addSubview:self.contentView];
  [self bringSubviewToFront:self.contentView];

  [UIView animateWithDuration:0.25 animations:^{
    self.contentView.frame = self.contentVisibleFrame;
    self.hidden = NO;
    self.contentIsVisible = YES;
  }];
}

- (void)dismissContent
{
  if (!self.contentIsVisible) {
    return;
  }

  [self.navigationItem setHidesBackButton:NO animated:YES];
  self.navigationItem.rightBarButtonItem = self.savedRightBarButton;

  [UIView animateWithDuration:0.25
                   animations:^{
                     self.contentView.frame = self.contentHiddenFrame;
                   }
                   completion:^(BOOL finished) {
                     [self.dismissButton removeFromSuperview];
                     [self.contentView removeFromSuperview];

                     self.frame = CGRectZero;
                     self.hidden = YES;
                     self.contentIsVisible = NO;
                   }];
}

@end
