//
//  OBBrewery.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBBrewery.h"
#import "OBRecipe.h"
#import "OBMalt.h"
#import "OBHops.h"
#import "OBYeast.h"
#import "Crittercism+NSErrorLogging.h"

@implementation OBBrewery

@dynamic mashEfficiency;
@dynamic defaultBatchSize;
@dynamic maltAdditionDisplayMetric;
@dynamic maltGaugeDisplayMetric;

+ (OBBrewery *)breweryFromContext:(NSManagedObjectContext *)moc
{
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"Brewery"
                                            inManagedObjectContext:moc];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSError *error = nil;
  NSArray *array = [moc executeFetchRequest:request error:&error];

  OBBrewery *brewery = nil;
  if (!error && array && array.count > 0) {
    NSAssert(array.count == 1, @"Multiple breweries found: %d", (int)array.count);
    brewery = array[0];
  } else {
    brewery = [self createBreweryInContext:moc];
  }

  return brewery;
}

+ (OBBrewery *)createBreweryInContext:(NSManagedObjectContext *)moc
{
  OBBrewery *brewery = [NSEntityDescription insertNewObjectForEntityForName:@"Brewery"
                                                     inManagedObjectContext:moc];

  if (![self loadMaltsIntoContext:moc]) {
    return nil;
  }

  if (![self loadHopsIntoContext:moc]) {
    return nil;
  }

  if (![self loadYeastIntoContext:moc]) {
    return nil;
  }

  return brewery;
}

+ (BOOL)loadYeastIntoContext:(NSManagedObjectContext *)moc
{
  return [self loadDataIntoContext:moc
                          fromPath:@"YeastCatalog.csv"
                         withBlock:^void (NSArray *attributes, NSManagedObjectContext *moc)
          {
            (void)[[OBYeast alloc] initWithContext:moc andCsvData:attributes];
          }];
}

+ (BOOL)loadMaltsIntoContext:(NSManagedObjectContext *)moc
{
  return [self loadDataIntoContext:moc
                          fromPath:@"MaltCatalog.csv"
                         withBlock:^void (NSArray *attributes, NSManagedObjectContext *moc)
          {
            (void)[[OBMalt alloc] initWithContext:moc andCsvData:attributes];
          }];
}

+ (BOOL)loadHopsIntoContext:(NSManagedObjectContext *)moc
{
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  return [self loadDataIntoContext:moc
                          fromPath:@"HopCatalog.csv"
                         withBlock:^void (NSArray *attributes, NSManagedObjectContext *moc)
          {
            (void)[[OBHops alloc] initWithContext:moc andCsvData:attributes];
          }];
}

+ (BOOL)loadDataIntoContext:(NSManagedObjectContext *)moc
                   fromPath:(NSString *)path
                  withBlock:(void (^)(NSArray *, NSManagedObjectContext *))parser
{
  NSString *csvPath = [[NSBundle mainBundle]
                       pathForResource:path
                       ofType:nil];

  NSError *error = nil;
  NSString *csv = [NSString stringWithContentsOfFile:csvPath
                                            encoding:NSUTF8StringEncoding
                                               error:&error];

  if (error) {
    CRITTERCISM_LOG_ERROR(error);
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
    
    parser([line componentsSeparatedByString:@","], moc);
  }

  return YES;
}

@end
