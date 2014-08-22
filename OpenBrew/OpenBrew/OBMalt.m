//
//  OBMalt.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMalt.h"
#import "OBIngredientCatalog.h"
#import "OBMaltAddition.h"

#define MALT_TYPE_GRAIN 0
#define MALT_TYPE_SUGAR 1
#define MALT_TYPE_EXTRACT 2

@implementation OBMalt

@dynamic defaultExtractPotential;
@dynamic defaultLovibond;
@dynamic name;
@dynamic catalog;
@dynamic maltAdditions;
@dynamic type;

- (BOOL)isGrain
{
  return [self.type intValue] == MALT_TYPE_GRAIN;
}

- (BOOL)isSugar
{
  return [self.type intValue] == MALT_TYPE_SUGAR;
}

- (BOOL)isExtract
{
  return [self.type intValue] == MALT_TYPE_EXTRACT;
}

@end
