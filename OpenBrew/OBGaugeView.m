//
//  OBGaugeView.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/6/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBGaugeView.h"

@implementation OBGaugeView

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
  UIView *view = [[NSBundle mainBundle] loadNibNamed:@"OBGaugeView" owner:self options:nil][0];
  view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
  [self addSubview:view];
}

@end
