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
#import "OBYeast.h"

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

  if (![self loadYeastIntoCatalog:catalog]) {
    return nil;
  }

  brewery.ingredientCatalog = catalog;

  return brewery;
}

+ (BOOL)loadYeastIntoCatalog:(OBIngredientCatalog *)catalog
{
  return [self loadDataIntoCatalog:catalog
                          fromPath:@"YeastCatalog.csv"
                         withBlock:^void (NSArray *attributes, OBIngredientCatalog *catalog)
          {
            OBYeast *yeast = [[OBYeast alloc] initWithCatalog:catalog andCsvData:attributes];
            [catalog addYeastObject:yeast];
          }];
}

+ (BOOL)loadMaltsIntoCatalog:(OBIngredientCatalog *)catalog
{
  return [self loadDataIntoCatalog:catalog
                          fromPath:@"MaltCatalog.csv"
                         withBlock:^void (NSArray *attributes, OBIngredientCatalog *catalog)
          {
            OBMalt *malt = [[OBMalt alloc] initWithCatalog:catalog andCsvData:attributes];
            [catalog addMaltsObject:malt];
          }];
}

+ (BOOL)loadHopsIntoCatalog:(OBIngredientCatalog *)catalog
{
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  return [self loadDataIntoCatalog:catalog
                          fromPath:@"HopCatalog.csv"
                         withBlock:^void (NSArray *attributes, OBIngredientCatalog *catalog)
          {
            OBHops *hops = [[OBHops alloc] initWithCatalog:catalog andCsvData:attributes];
            [catalog addHopsObject:hops];
          }];
}

+ (BOOL)loadDataIntoCatalog:(OBIngredientCatalog *)catalog
                   fromPath:(NSString *)path
                  withBlock:(void (^)(NSArray *, OBIngredientCatalog *))parser
{
  NSString *csvPath = [[NSBundle mainBundle]
                       pathForResource:path
                       ofType:nil];

  NSError *error = nil;
  NSString *csv = [NSString stringWithContentsOfFile:csvPath
                                            encoding:NSUTF8StringEncoding
                                               error:&error];

  if (error) {
    // TODO: log critter error
    NSLog(@"error %@", error);
    assert(NO);
    return NO;
  }

  NSArray *lines = [csv componentsSeparatedByCharactersInSet:
                    [NSCharacterSet newlineCharacterSet]];

  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  for (NSString *line in lines) {
    if (!line || line.length == 0) {
      continue;
    }
    
    parser([line componentsSeparatedByString:@","], catalog);
  }

  return YES;
}

@end
