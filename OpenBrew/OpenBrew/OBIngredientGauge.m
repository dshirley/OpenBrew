//
//  OBInstrumentGauge.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/7/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientGauge.h"

#define VALUE_HEIGHT 90
#define VALUE_FONT_SIZE 64

#define DESCRIPTION_Y (VALUE_HEIGHT - 10)
#define DESCRIPTION_HEIGHT 20


@implementation OBIngredientGauge

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
  _value = [[UILabel alloc] initWithFrame:[self valueBounds]];
  _description = [[UILabel alloc] initWithFrame:[self descriptionBounds]];
  
  _value.text = @"Default";
  _value.textColor = [UIColor blackColor];
  
  _description.text = @"Default";
  
  [self addSubview:_value];
  [self addSubview:_description];
}

- (CGRect)valueBounds
{
  return CGRectMake(0, 0, self.bounds.size.width, VALUE_HEIGHT);
}

- (CGRect)descriptionBounds
{
  return CGRectMake(0, DESCRIPTION_Y, self.bounds.size.width, DESCRIPTION_HEIGHT);
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  [_value setFrame:[self valueBounds]];
  [_value setTextAlignment:NSTextAlignmentCenter];
  [_value setFont:[UIFont systemFontOfSize:VALUE_FONT_SIZE]];
  
  [_description setFrame:[self descriptionBounds]];
  [_description setTextAlignment:NSTextAlignmentCenter];
  [_description setFont:[UIFont systemFontOfSize:12]];
  [_description setTextColor:[UIColor grayColor]];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  // Draw a horizontal line at the bottom of the gauge
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
  
  CGContextSetLineWidth(context, 1.0);
  
  CGFloat yPosn = VALUE_HEIGHT + DESCRIPTION_HEIGHT;
  CGContextMoveToPoint(context, 0, yPosn);
  CGContextAddLineToPoint(context, self.bounds.size.width, yPosn);
  
  CGContextStrokePath(context);
}


@end
