//
//  OBHops.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHops.h"
#import "OBHopAddition.h"
#import "OBIngredientCatalog.h"

#define HOP_NAME_IDX 0
#define HOP_ALPHA_IDX 1

@implementation OBHops

@dynamic catalog;
@dynamic defaultAlphaAcidPercent;
@dynamic name;

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
           andCsvData:(NSArray *)csvData
{
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  return [self initWithCatalog:catalog
                          name:csvData[HOP_NAME_IDX]
              alphaAcidPercent:[nf numberFromString:csvData[HOP_ALPHA_IDX]]];
}

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
                 name:(NSString *)name
     alphaAcidPercent:(NSNumber *)alphaAcidPercent
{
  NSManagedObjectContext *ctx = [catalog managedObjectContext];
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Hops"
                                          inManagedObjectContext:ctx];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:ctx]) {
    self.catalog = catalog;
    self.name = name;
    self.defaultAlphaAcidPercent = alphaAcidPercent;
  }

  return self;
}

@end
