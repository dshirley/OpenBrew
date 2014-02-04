//
//  OBMaltAddition.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltAddition.h"
#import "OBMalt.h"
#import "OBRecipe.h"


@implementation OBMaltAddition

@dynamic lovibond;
@dynamic extractPotential;
@dynamic quantityInPounds;
@dynamic malt;
@dynamic recipe;

- (float)gravityUnitsWithEfficiency:(float)efficiency {
  return [[self extractPotential] floatValue] * [[self quantityInPounds] floatValue] * efficiency;
}

@end
