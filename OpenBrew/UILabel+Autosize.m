//
//  UILabel+Autosize.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/17/16.
//  Copyright © 2016 OpenBrew. All rights reserved.
//

#import "UILabel+Autosize.h"

@implementation UILabel (Autosize)

- (void)resizeFontToMatchHeight
{
  [self layoutIfNeeded];

  UIFont *origFont = self.font;
  UIFont *newFont = [self findAdaptiveFontWithName:origFont.fontName
                                    forUILabelSize:self.frame.size
                                   withMinimumSize:self.frame.size.height];

  self.font = newFont;
}

// http://stackoverflow.com/questions/8812192/how-to-set-font-size-to-fill-uilabel-height
- (UIFont *)findAdaptiveFontWithName:(NSString *)fontName forUILabelSize:(CGSize)labelSize withMinimumSize:(NSInteger)minSize
{
  UIFont *tempFont = nil;
  NSString *testString = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

  NSInteger tempMin = minSize;
  NSInteger tempMax = 256;
  NSInteger mid = 0;
  NSInteger difference = 0;

  while (tempMin <= tempMax) {
    mid = tempMin + (tempMax - tempMin) / 2;
    tempFont = [UIFont fontWithName:fontName size:mid];

    CGSize tempFontSize = [testString sizeWithAttributes:@{NSFontAttributeName:tempFont}];
    difference = labelSize.height - tempFontSize.height;

    if (mid == tempMin || mid == tempMax) {
      if (difference < 0) {
        return [UIFont fontWithName:fontName size:(mid - 1)];
      }

      return [UIFont fontWithName:fontName size:mid];
    }

    if (difference < 0) {
      tempMax = mid - 1;
    } else if (difference > 0) {
      tempMin = mid + 1;
    } else {
      return [UIFont fontWithName:fontName size:mid];
    }
  }

  return [UIFont fontWithName:fontName size:mid];
}

@end
