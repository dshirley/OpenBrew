//
//  OBHopAddition.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OBIngredientAddition.h"
#import "OBHops.h"

@class OBRecipe;

typedef NS_ENUM(NSInteger, OBIbuFormula) {
  OBIbuFormulaTinseth,
  OBIbuFormulaRager
};

@interface OBHopAddition : OBHops <OBIngredientAddition>;

@property (nonatomic) NSNumber *boilTimeInMinutes;
@property (nonatomic) NSNumber *quantityInOunces;
@property (nonatomic) NSNumber *displayOrder;
@property (nonatomic) OBRecipe *recipe;

- (id)initWithHopVariety:(OBHops *)hopVariety andRecipe:(OBRecipe *)recipe;

- (float)ibusForRecipeVolume:(float)gallons boilGravity:(float)gravity ibuFormula:(OBIbuFormula)formula;
- (float)ibuContribution:(OBIbuFormula)ibuFormula;
- (float)tinsethUtilizationForGravity:(float)gravity;
- (float)ragerUtilization;
- (float)alphaAcidUnits;

- (NSNumber *)quantityInGrams;
- (void)setQuantityInGrams:(NSNumber *)quantityInGrams;

#pragma mark - OBIngredientAddition Protocol

- (void)removeFromRecipe;

@end
