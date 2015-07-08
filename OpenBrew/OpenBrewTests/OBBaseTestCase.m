//
//  OBBaseTestCase.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBMalt.h"
#import "OBMaltAddition.h"
#import "OBHops.h"
#import "OBHopAddition.h"
#import "OBYeast.h"
#import "OBYeastAddition.h"

@implementation OBBaseTestCase

- (void)setUp {
  [super setUp];
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OpenBrew"
                                            withExtension:@"momd"];

  self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
  XCTAssertNotNil([self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                configuration:nil
                                                                          URL:nil
                                                                      options:nil
                                                                        error:NULL]);

  self.ctx = [[NSManagedObjectContext alloc] init];
  self.ctx.persistentStoreCoordinator = self.persistentStoreCoordinator;

  self.brewery = [OBBrewery breweryFromContext:self.ctx];
  self.recipe = [[OBRecipe alloc] initWithContext:self.ctx];
}

- (void)tearDown {
  self.recipe = nil;
  self.ctx = nil;
  [super tearDown];
}

- (id)fetchEntity:(NSString *)entityName
     withProperty:(NSString *)property
          equalTo:(NSString *)value
{
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
                                                       inManagedObjectContext:self.ctx];

  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSString *query = [NSString stringWithFormat:@"(%@ == '%@')", property, value];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
  [request setPredicate:predicate];

  NSError *error = nil;
  NSArray *array = [self.ctx executeFetchRequest:request error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(array);
  XCTAssertEqual(1, array.count, @"%@", array);


  if (array.count >= 1) {
    return array[0];
  } else {
    return nil;
  }
}


#pragma mark Recipe Building Helper Methods

- (void)addMalt:(NSString *)maltName quantity:(float)quantity {
  [self addMalt:maltName quantity:quantity color:-1];
}

- (void)addMalt:(NSString *)maltName quantity:(float)quantity color:(float)color
{
  OBMalt *malt = [self fetchEntity:@"Malt" withProperty:@"name" equalTo:maltName];
  XCTAssertNotNil(malt);

  OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:malt andRecipe:self.recipe];
  maltAddition.quantityInPounds = @(quantity);

  if (color >= 0) {
    maltAddition.lovibond = @(color);
  }

  [self.recipe addMaltAdditionsObject:maltAddition];
}

- (void)addHops:(NSString *)hopsName quantity:(float)quantity aaPercent:(float)aaPercent boilTime:(float)boilTime
{
  OBHops *hops = [self fetchEntity:@"Hops" withProperty:@"name" equalTo:hopsName];
  XCTAssertNotNil(hops);

  OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:hops andRecipe:self.recipe];
  hopAddition.alphaAcidPercent = @(aaPercent);
  hopAddition.quantityInOunces = @(quantity);
  hopAddition.boilTimeInMinutes = @(boilTime);

  [self.recipe addHopAdditionsObject:hopAddition];
}

- (void)addYeast:(NSString *)identifier
{
  OBYeast *yeast = [self fetchEntity:@"Yeast" withProperty:@"identifier" equalTo:identifier];
  XCTAssertNotNil(yeast);

  OBYeastAddition *yeastAddition = [[OBYeastAddition alloc] initWithYeast:yeast andRecipe:self.recipe];
  self.recipe.yeast = yeastAddition;
}

@end
