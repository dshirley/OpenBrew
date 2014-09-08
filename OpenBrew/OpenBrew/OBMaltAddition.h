//
//  OBMaltAddition.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OBIngredientAddition.h"

@class OBMalt, OBRecipe;

@interface OBMaltAddition : NSManagedObject <OBIngredientAddition>

@property (nonatomic, retain) OBMalt *malt;
@property (nonatomic, retain) OBRecipe *recipe;

@property (nonatomic, retain) NSNumber *displayOrder;
@property (nonatomic, retain) NSNumber *lovibond;
@property (nonatomic, retain) NSNumber *extractPotential;
@property (nonatomic, retain) NSNumber *quantityInPounds;

- (id)initWithMalt:(OBMalt *)malt andRecipe:(OBRecipe *)recipe;

- (float)gravityUnitsWithEfficiency:(float)efficiency;

- (NSString *)name;

- (NSString *)quantityText;

// As described in "Designing Great Beers"
- (float)maltColorUnitsForBoilSize:(float)boilSize;

- (NSInteger)percentOfGravity;

#pragma mark - OBIngredientAddition protocol

- (void)removeFromRecipe;

@end
