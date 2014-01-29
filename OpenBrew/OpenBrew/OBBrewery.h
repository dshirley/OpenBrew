//
//  OBBrewery.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBRecipe;

@interface OBBrewery : NSManagedObject

@property (nonatomic, retain) NSNumber * mashEfficiency;
@property (nonatomic, retain) NSNumber * defaultBatchSize;
@property (nonatomic, retain) NSSet *recipes;
@end

@interface OBBrewery (CoreDataGeneratedAccessors)

+ (OBBrewery *)instance;

- (void)addRecipesObject:(OBRecipe *)value;
- (void)removeRecipesObject:(OBRecipe *)value;
- (void)addRecipes:(NSSet *)values;
- (void)removeRecipes:(NSSet *)values;

@end
