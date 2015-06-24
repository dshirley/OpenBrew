//
//  OBColorView.m
//  OpenBrew
//
//  Created by David Shirley 2 on 6/20/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBColorView.h"
#import "OBSrmColorTable.h"

@implementation OBColorView

- (void)setColorInSrm:(uint32_t)colorInSrm
{
  _colorInSrm = colorInSrm;
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];

  // Draw a horizontal line at the bottom of the gauge
  CGContextRef context = UIGraphicsGetCurrentContext();

  UIColor *darkColor = colorForSrm(self.colorInSrm + 1);
  UIColor *lightColor = nil;
  if (self.colorInSrm == 0) {
    darkColor = [UIColor whiteColor];
    lightColor = [UIColor whiteColor];
  } else {
    lightColor = colorForSrm(self.colorInSrm);
  }

  NSArray *colors = @[ darkColor, lightColor, [UIColor whiteColor]];
//  NSArray *colors = @[ colorForSrm(self.colorInSrm), colorForSrm(self.colorInSrm), [UIColor whiteColor]];
  NSMutableArray *cgColors = [[NSMutableArray alloc] init];
  for (UIColor *color in colors) {
    [cgColors addObject:(id)[color CGColor]];
  }

  CGFloat locations[3] = {0.0, 0.8, 1};

  //Default to the RGB Colorspace
  CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
  CFArrayRef arrayRef = (__bridge CFArrayRef)cgColors;

  CGGradientRef gradient = CGGradientCreateWithColors(myColorspace, arrayRef, locations);

  CGFloat endRadius = MIN(self.frame.size.width, self.frame.size.height) / 2;
  CGPoint center = { self.frame.size.width / 2, self.frame.size.height / 2 };
  CGContextDrawRadialGradient(context, gradient, center, 0, center, endRadius, kCGGradientDrawsAfterEndLocation);

}

@end
