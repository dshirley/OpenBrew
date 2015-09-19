//
//  OBTableViewPlaceholderLabel.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/7/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBPlaceholderView.h"

@implementation OBPlaceholderView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];

  if (self) {
    [self doInit];
  }

  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];

  if (self) {
    [self doInit];
  }

  return self;
}

- (void)doInit
{
  UIView *view = [[NSBundle mainBundle] loadNibNamed:@"OBPlaceholderView" owner:self options:nil][0];
  view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
  [self addSubview:view];
}



@end
