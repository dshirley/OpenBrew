//
//  IngredientCatalog.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBHops, OBMalt, OBYeast;

@interface OBIngredientCatalog : NSManagedObject

@property (nonatomic, retain) NSSet *hops;
@property (nonatomic, retain) NSSet *malts;
@property (nonatomic, retain) NSSet *yeast;
@end

@interface OBIngredientCatalog (CoreDataGeneratedAccessors)

- (void)addHopsObject:(OBHops *)value;
- (void)removeHopsObject:(OBHops *)value;
- (void)addHops:(NSSet *)values;
- (void)removeHops:(NSSet *)values;

- (void)addMaltsObject:(OBMalt *)value;
- (void)removeMaltsObject:(OBMalt *)value;
- (void)addMalts:(NSSet *)values;
- (void)removeMalts:(NSSet *)values;

- (void)addYeastObject:(OBYeast *)value;
- (void)removeYeastObject:(OBYeast *)value;
- (void)addYeast:(NSSet *)values;
- (void)removeYeast:(NSSet *)values;

@end
