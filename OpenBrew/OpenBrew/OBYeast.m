//
//  OBYeast.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBYeast.h"

@implementation OBYeast
@dynamic company;
@dynamic name;
@dynamic referenceLink;
@dynamic attanuationMaxPercent;
@dynamic attanuationMinPercent;

- (float)estimatedAttenuationAsDecimal {
  return ([self attanuationMinPercent] + [self attanuationMaxPercent]) / 2;
}

@end

@implementation OBYeastAddition
@dynamic yeast;
@dynamic quantity;
@end