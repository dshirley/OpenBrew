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

// This is the final volume of beer that can be consumed.
@property (nonatomic, retain) NSNumber * batchSizeInGallons;
@property (nonatomic, retain) NSNumber * boilOffInGallons;
@property (nonatomic, retain) NSNumber *fermentorLossageInGallons;
@property (nonatomic, retain) NSNumber *kettleLossageInGallons;

@property (nonatomic, retain) OBBrewery *brewery;
@property (nonatomic, retain) NSSet *hopAdditions;
@property (nonatomic, retain) NSSet *maltAdditions;

- (id)initWithContext:(NSManagedObjectContext *)context;

- (float)boilSizeInGallons;
- (float)postBoilSizeInGallons;
- (float)boilGravity;
- (float)gravityUnits;
- (float)originalGravity;
- (float)finalGravity;
- (float)IBUs;
- (float)colorInSRM;
- (float)alcoholByVolume;
- (float)bitternessToGravityRatio;
- (float)ibusForHopAddition:(OBHopAddition *)hopAddition;
- (NSInteger)percentTotalGravityOfMaltAddition:(OBMaltAddition *)maltAddition;
- (NSInteger)percentIBUOfHopAddition:(OBHopAddition *)hopAddition;

@end

@interface OBRecipe (CoreDataGeneratedAccessors)

- (void)addHopAdditionsObject:(OBHopAddition *)value;
- (void)removeHopAdditionsObject:(OBHopAddition *)value;

- (void)addMaltAdditionsObject:(OBMaltAddition *)value;
- (void)removeMaltAdditionsObject:(OBMaltAddition *)value;

@end
