//
//  OBDataLoader.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OBDataLoader.h"
#import "OBSettings.h"
#import "OBMalt.h"
#import "OBHops.h"
#import "OBYeast.h"
#import "OBMaltAddition.h"
#import "OBHopAddition.h"
#import "OBYeastAddition.h"
#import "OBRecipe.h"

@interface OBDataLoader()

@property (nonatomic) NSManagedObjectContext *moc;
@end

@implementation OBDataLoader

- (instancetype)initWithContext:(NSManagedObjectContext *)moc;
{
  self = [super init];

  if (self) {

    self.moc = moc;
  }

  return self;
}


#pragma mark - Data Loading

- (BOOL)loadIngredients
{
  return [self loadYeast] && [self loadMalts] && [self loadHops];
}

- (BOOL)loadYeast
{
  return [self loadDataIntoContext:self.moc
                          fromPath:@"YeastCatalog.csv"
                         withBlock:^void (NSArray *attributes, NSManagedObjectContext *moc)
          {
            (void)[[OBYeast alloc] initWithContext:moc andCsvData:attributes];
          }];
}

- (BOOL)loadMalts
{
  return [self loadDataIntoContext:self.moc
                          fromPath:@"MaltCatalog.csv"
                         withBlock:^void (NSArray *attributes, NSManagedObjectContext *moc)
          {
            (void)[[OBMalt alloc] initWithContext:moc andCsvData:attributes];
          }];
}

- (BOOL)loadHops
{
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  return [self loadDataIntoContext:self.moc
                          fromPath:@"HopCatalog.csv"
                         withBlock:^void (NSArray *attributes, NSManagedObjectContext *moc)
          {
            (void)[[OBHops alloc] initWithContext:moc andCsvData:attributes];
          }];
}

- (BOOL)loadSampleRecipes
{
  OBRecipe *recipe = [[OBRecipe alloc] initWithContext:self.moc];
  recipe.name = @"Oatmeal Stout";
  recipe.preBoilVolumeInGallons = @(7.0);
  recipe.postBoilVolumeInGallons = @(6.0);
  [self addMalt:@"Maris Otter" quantity:7.0 toRecipe:recipe];
  [self addMalt:@"Oats" quantity:1.0 toRecipe:recipe];
  [self addMalt:@"Victory" quantity:1.0 toRecipe:recipe];
  [self addMalt:@"Crystal 80" quantity:0.5 toRecipe:recipe];
  [self addMalt:@"Roasted Barley" quantity:0.5 toRecipe:recipe];
  [self addHops:@"Cascade" quantity:0.75 aaPercent:5.8 boilTime:60 toRecipe:recipe];
  [self addHops:@"Citra" quantity:0.4 aaPercent:13.9 boilTime:60 toRecipe:recipe];
  [self addYeast:@"WLP002" toRecipe:recipe];

  recipe = [[OBRecipe alloc] initWithContext:self.moc];
  recipe.name = @"Session IPA";
  recipe.preBoilVolumeInGallons = @(7.0);
  recipe.postBoilVolumeInGallons = @(6.0);
  [self addMalt:@"Two-Row" quantity:5.0 toRecipe:recipe];
  [self addMalt:@"Vienna" quantity:4.0 toRecipe:recipe];
  [self addMalt:@"Crystal 20" quantity:0.5 toRecipe:recipe];
  [self addMalt:@"Wheat Light" quantity:1.0 toRecipe:recipe];
  [self addHops:@"Columbus" quantity:0.7 aaPercent:14.3 boilTime:60 toRecipe:recipe];
  [self addHops:@"Simcoe" quantity:0.5 aaPercent:11.8 boilTime:20 toRecipe:recipe];
  [self addHops:@"Simcoe" quantity:0.6 aaPercent:11.8 boilTime:3 toRecipe:recipe];
  [self addHops:@"Amarillo" quantity:1.0 aaPercent:8.2 boilTime:3 toRecipe:recipe];
  [self addHops:@"Citra" quantity:0.4 aaPercent:14.0 boilTime:3 toRecipe:recipe];
  [self addYeast:@"WLP001" toRecipe:recipe];

  recipe = [[OBRecipe alloc] initWithContext:self.moc];
  recipe.name = @"SMaSH Hit";
  recipe.preBoilVolumeInGallons = @(7.0);
  recipe.postBoilVolumeInGallons = @(6.0);
  [self addMalt:@"Vienna" quantity:15.0 toRecipe:recipe];
  [self addHops:@"Saaz" quantity:2.0 aaPercent:4.0 boilTime:60 toRecipe:recipe];
  [self addHops:@"Saaz" quantity:0.5 aaPercent:4.0 boilTime:20 toRecipe:recipe];
  [self addYeast:@"WLP833" toRecipe:recipe];
  
  return YES;
}

- (BOOL)loadDataIntoContext:(NSManagedObjectContext *)moc
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

  NSAssert(!error, @"An error occurred loading %@: %@", csvPath, error);
  if (error) {
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

#pragma mark Recipe Building Helper Methods

- (id)fetchEntity:(NSString *)entityName
     withProperty:(NSString *)property
          equalTo:(NSString *)value
{
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
                                                       inManagedObjectContext:self.moc];

  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  request.entity = entityDescription;
  request.includesSubentities = NO;

  NSString *query = [NSString stringWithFormat:@"(%@ == '%@')", property, value];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
  [request setPredicate:predicate];

  NSError *error = nil;
  NSArray *array = [self.moc executeFetchRequest:request error:&error];
  NSAssert(!error, @"error: %@", error);
  NSAssert(array, @"nil array");
  NSAssert(array.count == 1, @"array has more than one element: %@", array);

  if (array.count >= 1) {
    return array[0];
  } else {
    return nil;
  }
}

- (OBMaltAddition *)addMalt:(NSString *)maltName quantity:(float)quantity toRecipe:(OBRecipe *)recipe
{
  OBMalt *malt = [self fetchEntity:@"Malt" withProperty:@"name" equalTo:maltName];
  NSAssert(malt, @"Malt was nil: %@", maltName);

  OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:malt andRecipe:recipe];
  maltAddition.quantityInPounds = @(quantity);

  return maltAddition;
}

- (OBHopAddition *)addHops:(NSString *)hopsName
                  quantity:(float)quantity
                 aaPercent:(float)aaPercent
                  boilTime:(float)boilTime
                  toRecipe:(OBRecipe *)recipe
{
  OBHops *hops = [self fetchEntity:@"Hops" withProperty:@"name" equalTo:hopsName];
  NSAssert(hops, @"Hops were nil: %@", hopsName);

  OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:hops andRecipe:recipe];
  hopAddition.alphaAcidPercent = @(aaPercent);
  hopAddition.quantityInOunces = @(quantity);
  hopAddition.boilTimeInMinutes = @(boilTime);

  return hopAddition;
}

- (OBYeastAddition *)addYeast:(NSString *)identifier toRecipe:(OBRecipe *)recipe
{
  OBYeast *yeast = [self fetchEntity:@"Yeast" withProperty:@"identifier" equalTo:identifier];
  NSAssert(yeast, @"Yeast was nil: %@", identifier);

  return [[OBYeastAddition alloc] initWithYeast:yeast andRecipe:recipe];
}

@end
