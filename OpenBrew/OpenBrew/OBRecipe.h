//
//  OBRecipe.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBYeast.h"
#import "OBMalt.h"
#import "OBHops.h"

@interface OBRecipe : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) OBYeastAddition *yeast;
@property (nonatomic) float batchSizeInGallons;

@property (nonatomic, strong) NSSet *malts;
@property (nonatomic, strong) NSSet *hops;

- (void)addMaltsObject:(OBMaltAddition *)maltAddition;
- (void)addHopsObject:(OBHopAddition *)hopAddition;

- (float)boilSizeInGallons;
- (float)postBoilSizeInGallons;
- (float)boilGravity;
- (float)gravityUnits;
- (float)originalGravity;
- (float)finalGravity;
- (float)IBUs;
- (float)alcoholByVolume;

- (void)save;

@end
