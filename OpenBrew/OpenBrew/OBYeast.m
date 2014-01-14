//
//  OBYeast.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBYeast.h"

@implementation OBYeast

- (float)estimatedAttenuationAsDecimal {
  return [_attenuationRange average];
}

@end
