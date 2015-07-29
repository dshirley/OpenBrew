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

  self.r0s0 = [NSIndexPath indexPathForRow:0 inSection:0];
  self.r1s0 = [NSIndexPath indexPathForRow:1 inSection:0];
  self.r2s0 = [NSIndexPath indexPathForRow:2 inSection:0];
  self.r3s0 = [NSIndexPath indexPathForRow:3 inSection:0];
  self.r4s0 = [NSIndexPath indexPathForRow:4 inSection:0];
  self.r5s0 = [NSIndexPath indexPathForRow:5 inSection:0];
}

- (void)tearDown {
  self.recipe = nil;
  self.ctx = nil;
  [super tearDown];
}

- (NSArray *)fetchAllEntity:(NSString *)entityName
{
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:entityName
                                            inManagedObjectContext:self.ctx];

  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSError *error = nil;
  NSArray *array = [self.ctx executeFetchRequest:request error:&error];

  XCTAssertNil(error);

  return array;
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

- (OBMaltAddition *)addMalt:(NSString *)maltName quantity:(float)quantity {
  return [self addMalt:maltName quantity:quantity color:-1];
}

- (OBMaltAddition *)addMalt:(NSString *)maltName quantity:(float)quantity color:(float)color
{
  OBMalt *malt = [self fetchEntity:@"Malt" withProperty:@"name" equalTo:maltName];
  XCTAssertNotNil(malt);

  OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:malt andRecipe:self.recipe];
  maltAddition.quantityInPounds = @(quantity);

  if (color >= 0) {
    maltAddition.lovibond = @(color);
  }

  [self.recipe addMaltAdditionsObject:maltAddition];

  return maltAddition;
}

- (OBHopAddition *)addHops:(NSString *)hopsName quantity:(float)quantity aaPercent:(float)aaPercent boilTime:(float)boilTime
{
  OBHops *hops = [self fetchEntity:@"Hops" withProperty:@"name" equalTo:hopsName];
  XCTAssertNotNil(hops);

  OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:hops andRecipe:self.recipe];
  hopAddition.alphaAcidPercent = @(aaPercent);
  hopAddition.quantityInOunces = @(quantity);
  hopAddition.boilTimeInMinutes = @(boilTime);

  [self.recipe addHopAdditionsObject:hopAddition];

  return hopAddition;
}

- (OBYeastAddition *)addYeast:(NSString *)identifier
{
  OBYeast *yeast = [self fetchEntity:@"Yeast" withProperty:@"identifier" equalTo:identifier];
  XCTAssertNotNil(yeast);

  OBYeastAddition *yeastAddition = [[OBYeastAddition alloc] initWithYeast:yeast andRecipe:self.recipe];
  self.recipe.yeast = yeastAddition;

  return yeastAddition;
}

@end
