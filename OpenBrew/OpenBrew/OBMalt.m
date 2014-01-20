//
//  OBMalt.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMalt.h"

@implementation OBMalt
@dynamic name;
@dynamic defaultLovibond;
@dynamic defaultMaxYield;
@end


@implementation OBMaltAddition

@dynamic malt;
@dynamic quantityInPounds;
@dynamic maxYield;
@dynamic lovibond;

- (float)gravityUnitsWithEfficiency:(float)efficiency {
  return [self maxYield] * [self quantityInPounds] * efficiency;
}

@end