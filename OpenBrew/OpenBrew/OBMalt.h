//
//  OBMalt.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBIngredientCatalog, OBMaltAddition;

@interface OBMalt : NSManagedObject

@property (nonatomic, retain) OBIngredientCatalog *catalog;

@property (nonatomic, retain) NSString *name;

// Malt, sugar, extract
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSNumber *defaultLovibond;
@property (nonatomic, retain) NSNumber *defaultExtractPotential;
@property (nonatomic, retain) NSSet *maltAdditions;

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
           andCsvData:(NSArray *)data;

- (BOOL)isGrain;
- (BOOL)isSugar;
- (BOOL)isExtract;

@end

@interface OBMalt (CoreDataGeneratedAccessors)

- (void)addMaltAdditionsObject:(OBMaltAddition *)value;
- (void)removeMaltAdditionsObject:(OBMaltAddition *)value;
- (void)addMaltAdditions:(NSSet *)values;
- (void)removeMaltAdditions:(NSSet *)values;

@end
