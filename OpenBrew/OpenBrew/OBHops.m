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

@dynamic defaultAlphaAcidPercent;
@dynamic name;

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
           andCsvData:(NSArray *)csvData
{
  NSManagedObjectContext *ctx = [catalog managedObjectContext];
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Hops"
                                          inManagedObjectContext:ctx];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:ctx]) {
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];

    self.name = csvData[HOP_NAME_IDX];
    self.defaultAlphaAcidPercent = [nf numberFromString:csvData[HOP_ALPHA_IDX]];
  }

  return self;

}

@end
