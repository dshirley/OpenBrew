//
//  OBRecipe.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBBrewery, OBHopAddition, OBMaltAddition, OBYeastAddition;

@interface OBRecipe : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) OBYeastAddition *yeast;
@property (nonatomic, retain) NSNumber * batchSizeInGallons;

@property (nonatomic, retain) OBBrewery *brewery;
@property (nonatomic, retain) NSSet *hopAdditions;
@property (nonatomic, retain) NSSet *maltAdditions;

- (id)initWithContext:(NSManagedObjectContext *)context;

@end

@interface OBRecipe (CoreDataGeneratedAccessors)

- (void)addHopAdditionsObject:(OBHopAddition *)value;
- (void)removeHopAdditionsObject:(OBHopAddition *)value;
- (void)addHopAdditions:(NSSet *)values;
- (void)removeHopAdditions:(NSSet *)values;

- (void)addMaltAdditionsObject:(OBMaltAddition *)value;
- (void)removeMaltAdditionsObject:(OBMaltAddition *)value;
- (void)addMaltAdditions:(NSSet *)values;
- (void)removeMaltAdditions:(NSSet *)values;

- (float)boilSizeInGallons;
- (float)postBoilSizeInGallons;
- (float)boilGravity;
- (float)gravityUnits;
- (float)originalGravity;
- (float)finalGravity;
- (float)IBUs;
- (float)alcoholByVolume;

@end
