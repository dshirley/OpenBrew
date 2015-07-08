//
//  OBBaseTestCase.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//
//  This base test case is all about making other tests more convenient.
//  Almost every test will require a brewery and a recipe in order to do anything.
//  This test sets up the scaffolding to make testing easier.

#import "OBBrewery.h"
#import "OBRecipe.h"

@interface OBBaseTestCase : XCTestCase
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *ctx;
@property (nonatomic, strong) OBBrewery *brewery;
@property (nonatomic, strong) OBRecipe *recipe;

// For example:
// [self fetchEntity:@"Malt" withProperty:@"name" equalTo:@"Pilsner Malt"]
- (id)fetchEntity:(NSString *)entityName
     withProperty:(NSString *)property
          equalTo:(NSString *)value;

- (void)addMalt:(NSString *)maltName quantity:(float)quantity;

- (void)addMalt:(NSString *)maltName quantity:(float)quantity color:(float)color;

- (void)addHops:(NSString *)hopsName quantity:(float)quantity aaPercent:(float)aaPercent boilTime:(float)boilTime;

- (void)addYeast:(NSString *)identifier;

@end
