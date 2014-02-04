//
//  OBYeast.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBYeast.h"
#import "OBIngredientCatalog.h"
#import "OBYeastAddition.h"


@implementation OBYeast

@dynamic company;
@dynamic name;
@dynamic referenceLink;
@dynamic attenuationMaxPercent;
@dynamic attenuationMinPercent;

- (float)estimatedAttenuationAsDecimal {
  float min = [[self attenuationMinPercent] floatValue];
  float max = [[self attenuationMaxPercent] floatValue];
  return (min + max) / 2;
}

@end
