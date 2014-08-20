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

  [self loadMaltsIntoCatalog:catalog];
  [self loadHopsIntoCatalog:catalog];

  brewery.ingredientCatalog = catalog;

  return brewery;
}

+ (void)loadMaltsIntoCatalog:(OBIngredientCatalog *)catalog
{
  // TODO: return "FALSE" and don't load brewery if one of these fails. Log a critter error, too
  NSString *maltCatalogPath = [[NSBundle mainBundle]
                               pathForResource:@"MaltCatalog.csv"
                               ofType:nil];

  NSString *maltCatalogCsv = [NSString stringWithContentsOfFile:maltCatalogPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];

  NSArray *malts = [maltCatalogCsv componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  for (NSString *maltData in malts) {
    NSArray *attributes = [maltData componentsSeparatedByString:@","];

    OBMalt *malt = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Malt"
                    inManagedObjectContext:catalog.managedObjectContext];

    // TODO: get rid of magic numbers
    malt.name = attributes[0];
    malt.defaultExtractPotential = [nf numberFromString:attributes[1]];
    malt.defaultLovibond = [nf numberFromString:attributes[2]];

    [catalog addMaltsObject:malt];
  }
}

+ (void)loadHopsIntoCatalog:(OBIngredientCatalog *)catalog
{
  // TODO: return false if any of these fail
  NSString *hopCatalogPath = [[NSBundle mainBundle]
                              pathForResource:@"HopCatalog.csv"
                              ofType:nil];

  NSString *hopCatalogCsv = [NSString stringWithContentsOfFile:hopCatalogPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];

  NSArray *hops = [hopCatalogCsv componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  for (NSString *hopData in hops) {
    NSArray *attributes = [hopData componentsSeparatedByString:@","];

    OBHops *hops = [NSEntityDescription insertNewObjectForEntityForName:@"Hops"
                                                 inManagedObjectContext:catalog.managedObjectContext];

    // TODO: get rid of magic numbers
    hops.name = attributes[0];
    hops.defaultAlphaAcidPercent = [nf numberFromString:attributes[1]];

    [catalog addHopsObject:hops];
  }

}

@end
