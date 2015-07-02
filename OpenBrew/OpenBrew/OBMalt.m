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
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  return [self initWithCatalog:catalog
                          name:csvData[MALT_NAME_IDX]
              extractPotential:[nf numberFromString:csvData[MALT_EXTRACT_IDX]]
                      lovibond:[nf numberFromString:csvData[MALT_COLOR_IDX]]
                          type:[nf numberFromString:csvData[MALT_TYPE_IDX]]];
}

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
                 name:(NSString *)name
     extractPotential:(NSNumber *)extractPotential
             lovibond:(NSNumber *)lovibond
                 type:(NSNumber *)type
{
  NSManagedObjectContext *ctx = [catalog managedObjectContext];
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Malt"
                                          inManagedObjectContext:ctx];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:ctx]) {
    self.catalog = catalog;
    self.name = name;
    self.defaultExtractPotential = extractPotential;
    self.defaultLovibond = lovibond;
    self.type = type;
  }

  return self;
}

- (BOOL)isGrain
{
  return [self.type intValue] == OBMaltTypeGrain;
}

- (BOOL)isSugar
{
  return [self.type intValue] == OBMaltTypeSugar;
}

- (BOOL)isExtract
{
  return [self.type intValue] == OBMaltTypeExtract;
}

@end
