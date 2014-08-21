//
//  OBBrewery.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBBrewery.h"
#import "OBRecipe.h"
#import "OBIngredientCatalog.h"
#import "OBMalt.h"
#import "OBHops.h"

#define MALT_NAME_IDX 0
#define MALT_EXTRACT_IDX 1
#define MALT_COLOR_IDX 2

#define HOP_NAME_IDX 0
#define HOP_ALPHA_IDX 1

@implementation OBBrewery

@dynamic mashEfficiency;
@dynamic defaultBatchSize;
@dynamic recipes;
@dynamic ingredientCatalog;

+ (OBBrewery *)instance {
  return nil;
}

+ (OBBrewery *)breweryFromContext:(NSManagedObjectContext *)ctx
{
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"Brewery"
                                            inManagedObjectContext:ctx];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSError *error = nil;
  NSArray *array = [ctx executeFetchRequest:request error:&error];

  OBBrewery *brewery = nil;
  if (!error && array && array.count > 0) {
    brewery = array[0];
  } else {
    brewery = [self createBreweryInContext:ctx];
  }

  return brewery;
}

+ (OBBrewery *)createBreweryInContext:(NSManagedObjectContext *)ctx
{
  OBBrewery *brewery = [NSEntityDescription insertNewObjectForEntityForName:@"Brewery"
                                                     inManagedObjectContext:ctx];

  OBIngredientCatalog *catalog = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"IngredientCatalog"
                                  inManagedObjectContext:ctx];

  if (![self loadMaltsIntoCatalog:catalog]) {
    return nil;
  }

  if (![self loadHopsIntoCatalog:catalog]) {
    return nil;
  }

  brewery.ingredientCatalog = catalog;

  return brewery;
}

+ (BOOL)loadMaltsIntoCatalog:(OBIngredientCatalog *)catalog
{
  NSString *maltCatalogPath = [[NSBundle mainBundle]
                               pathForResource:@"MaltCatalog.csv"
                               ofType:nil];

  NSError *error = nil;
  NSString *maltCatalogCsv = [NSString stringWithContentsOfFile:maltCatalogPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];

  if (error) {
    // TODO: log Critter error
    return NO;
  }

  NSArray *malts = [maltCatalogCsv componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  for (NSString *maltData in malts) {
    NSArray *attributes = [maltData componentsSeparatedByString:@","];

    OBMalt *malt = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Malt"
                    inManagedObjectContext:catalog.managedObjectContext];

    malt.name = attributes[MALT_NAME_IDX];
    malt.defaultExtractPotential = [nf numberFromString:attributes[MALT_EXTRACT_IDX]];
    malt.defaultLovibond = [nf numberFromString:attributes[MALT_COLOR_IDX]];

    [catalog addMaltsObject:malt];
  }

  return YES;
}

+ (BOOL)loadHopsIntoCatalog:(OBIngredientCatalog *)catalog
{
  NSString *hopCatalogPath = [[NSBundle mainBundle]
                              pathForResource:@"HopCatalog.csv"
                              ofType:nil];

  NSError *error = nil;
  NSString *hopCatalogCsv = [NSString stringWithContentsOfFile:hopCatalogPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];

  if (error) {
    // TODO: log critter error
    return NO;
  }

  NSArray *hops = [hopCatalogCsv componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  for (NSString *hopData in hops) {
    NSArray *attributes = [hopData componentsSeparatedByString:@","];

    OBHops *hops = [NSEntityDescription insertNewObjectForEntityForName:@"Hops"
                                                 inManagedObjectContext:catalog.managedObjectContext];

    hops.name = attributes[HOP_NAME_IDX];
    hops.defaultAlphaAcidPercent = [nf numberFromString:attributes[HOP_ALPHA_IDX]];

    [catalog addHopsObject:hops];
  }

  return YES;
}

@end
