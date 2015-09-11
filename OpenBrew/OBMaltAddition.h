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
#import "OBMalt.h"

@class OBRecipe;

@interface OBMaltAddition : OBMalt <OBIngredientAddition>

@property (nonatomic) OBRecipe *recipe;

@property (nonatomic) NSNumber *displayOrder;
@property (nonatomic) NSNumber *quantityInPounds;

- (id)initWithMalt:(OBMalt *)malt andRecipe:(OBRecipe *)recipe;

- (float)gravityUnitsWithEfficiency:(float)efficiency;

- (NSString *)quantityText;

// As described in "Designing Great Beers"
- (float)maltColorUnitsForBoilSize:(float)boilSize;

- (NSInteger)percentOfGravity;

#pragma mark - OBIngredientAddition protocol

- (void)removeFromRecipe;

@end
