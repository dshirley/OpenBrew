//
//  OBRange.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/14/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRange.h"

@implementation OBRange

- (id)initWithLowEnd:(float)lowEnd andHighEnd:(float)highEnd {
  if (!self) {
    return nil;
  }

  _lowEnd = lowEnd;
  _highEnd = highEnd;
  
  return self;
}

@end
