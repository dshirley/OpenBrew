//
//  OBBaseTestCase.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//
//  This base test case is all about making other tests more convenient.
//  Almost every test will require a settings and a recipe in order to do anything.
//  This test sets up the scaffolding to make testing easier.

#import "OBSettings.h"
#import "OBRecipe.h"

@interface OBBaseTestCase : XCTestCase
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *ctx;
@property (nonatomic, strong) OBSettings *settings;
@property (nonatomic, strong) OBRecipe *recipe;

// Some index paths that are used throughout many controller tests
@property (nonatomic) NSIndexPath *r0s0;
@property (nonatomic) NSIndexPath *r1s0;
@property (nonatomic) NSIndexPath *r2s0;
@property (nonatomic) NSIndexPath *r3s0;
@property (nonatomic) NSIndexPath *r4s0;
@property (nonatomic) NSIndexPath *r5s0;

- (NSArray *)fetchAllEntity:(NSString *)entityName;

// For example:
// [self fetchEntity:@"Malt" withProperty:@"name" equalTo:@"Pilsner Malt"]
- (id)fetchEntity:(NSString *)entityName
     withProperty:(NSString *)property
          equalTo:(NSString *)value;

- (OBMaltAddition *)addMalt:(NSString *)maltName quantity:(float)quantity;

- (OBMaltAddition *)addMalt:(NSString *)maltName quantity:(float)quantity color:(float)color;

- (OBHopAddition *)addHops:(NSString *)hopsName quantity:(float)quantity aaPercent:(float)aaPercent boilTime:(float)boilTime;

- (OBYeastAddition *)addYeast:(NSString *)identifier;

@end
