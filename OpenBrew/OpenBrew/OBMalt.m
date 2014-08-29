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


#define MALT_NAME_IDX 0
#define MALT_EXTRACT_IDX 1
#define MALT_COLOR_IDX 2
#define MALT_TYPE_IDX 3

@implementation OBMalt

@dynamic defaultExtractPotential;
@dynamic defaultLovibond;
@dynamic name;
@dynamic catalog;
@dynamic maltAdditions;
@dynamic type;

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
           andCsvData:(NSArray *)csvData
{
  NSManagedObjectContext *ctx = [catalog managedObjectContext];
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Malt"
                                          inManagedObjectContext:ctx];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:ctx]) {
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];

    self.catalog = catalog;
    self.name = csvData[MALT_NAME_IDX];
    self.defaultExtractPotential = [nf numberFromString:csvData[MALT_EXTRACT_IDX]];
    self.defaultLovibond = [nf numberFromString:csvData[MALT_COLOR_IDX]];
    self.type = [nf numberFromString:csvData[MALT_TYPE_IDX]];
  }

  return self;
}

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
