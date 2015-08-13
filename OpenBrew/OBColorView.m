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

  NSArray *colors = nil;
  CGFloat twolocations[2] = { 0.0, 1.0 };
  CGFloat threeLocations[3] = { 0.0, 0.8, 1.0 };
  CGFloat *locations = NULL;

  if (self.colorInSrm == 0) {
    colors = @[[UIColor colorWithRed:(192.0 / 255.0) green:(237.0 / 255.0) blue:(254.0 / 255.0) alpha:1.0],
               [UIColor whiteColor]];
    locations = twolocations;
  } else {
    colors = @[colorForSrm(self.colorInSrm + 1),
               colorForSrm(self.colorInSrm),
               [UIColor whiteColor]];
    locations = threeLocations;
  }

  NSMutableArray *cgColors = [[NSMutableArray alloc] init];
  for (UIColor *color in colors) {
    [cgColors addObject:(id)[color CGColor]];
  }

  //Default to the RGB Colorspace
  CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
  CFArrayRef arrayRef = (__bridge CFArrayRef)cgColors;

  CGGradientRef gradient = CGGradientCreateWithColors(myColorspace, arrayRef, locations);

  CGFloat endRadius = MIN(self.frame.size.width, self.frame.size.height) / 2;
  CGPoint center = { self.frame.size.width / 2, self.frame.size.height / 2 };
  CGContextDrawRadialGradient(context, gradient, center, 0, center, endRadius, kCGGradientDrawsAfterEndLocation);

  CGGradientRelease(gradient);
  CGColorSpaceRelease(myColorspace);
}

@end
