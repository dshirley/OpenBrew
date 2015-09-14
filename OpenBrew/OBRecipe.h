//
//  OBRecipe.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OBHopAddition.h"

@class OBSettings, OBMaltAddition, OBYeastAddition;

@interface OBRecipe : NSManagedObject

@property (nonatomic) NSString *name;
@property (nonatomic) OBYeastAddition *yeast;

@property (nonatomic) NSNumber *postBoilVolumeInGallons;
@property (nonatomic) NSNumber *preBoilVolumeInGallons;

@property (nonatomic) OBSettings *settings;
@property (nonatomic) NSSet *hopAdditions;
@property (nonatomic) NSSet *maltAdditions;

@property (nonatomic) NSNumber *mashEfficiency;

- (id)initWithContext:(NSManagedObjectContext *)context;

- (float)boilGravity;
- (float)gravityUnits;
- (float)originalGravity;
- (float)finalGravity;
- (float)IBUs:(OBIbuFormula)ibuFormula;
- (float)colorInSRM;
- (float)alcoholByVolume;
- (float)bitternessToGravityRatio:(OBIbuFormula)ibuFormula;
- (float)ibusForHopAddition:(OBHopAddition *)hopAddition ibuFormula:(OBIbuFormula)ibuFormula;
- (NSInteger)percentTotalGravityOfMaltAddition:(OBMaltAddition *)maltAddition;

- (NSArray *)maltAdditionsSorted;
- (NSArray *)hopAdditionsSorted;

@end

@interface OBRecipe (CoreDataGeneratedAccessors)

- (void)addHopAdditionsObject:(OBHopAddition *)value;
- (void)removeHopAdditionsObject:(OBHopAddition *)value;

- (void)addMaltAdditionsObject:(OBMaltAddition *)value;
- (void)removeMaltAdditionsObject:(OBMaltAddition *)value;

@end
