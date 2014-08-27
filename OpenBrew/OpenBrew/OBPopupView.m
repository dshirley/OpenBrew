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

@end

@implementation OBPopupView

- (id)initWithFrame:(CGRect)frame andContentView:(UIView *)view
{
    self = [super initWithFrame:CGRectZero];

    if (self) {
      _parentFrame = frame;
      _contentIsVisible = NO;
      _contentView = view;

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
  // TODO: could this view adjust the nav bar?  Seems out of place

  if (self.contentIsVisible) {
    return;
  }

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
