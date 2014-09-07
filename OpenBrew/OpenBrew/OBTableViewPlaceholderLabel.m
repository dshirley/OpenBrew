//
//  OBTableViewPlaceholderLabel.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/7/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBTableViewPlaceholderLabel.h"

@implementation OBTableViewPlaceholderLabel

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text
{
    self = [super initWithFrame:frame];

    if (self) {
      self.text = text;
      self.textColor = [UIColor grayColor];
      self.textAlignment = NSTextAlignmentCenter;
      self.font = [UIFont systemFontOfSize:24];
    }

    return self;
}

@end
