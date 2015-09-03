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

@class OBHops, OBRecipe;


typedef NS_ENUM(NSInteger, OBIbuFormula) {
  OBIbuFormulaTinseth,
  OBIbuFormulaRager
};

@interface OBHopAddition : NSManagedObject <OBIngredientAddition>;

@property (nonatomic) NSString *name;
@property (nonatomic) NSNumber *alphaAcidPercent;
@property (nonatomic) NSNumber *boilTimeInMinutes;
@property (nonatomic) NSNumber *quantityInOunces;
@property (nonatomic) NSNumber *displayOrder;
@property (nonatomic) OBRecipe *recipe;

- (id)initWithHopVariety:(OBHops *)hopVariety andRecipe:(OBRecipe *)recipe;

- (float)ibusForRecipeVolume:(float)gallons boilGravity:(float)gravity ibuFormula:(OBIbuFormula)formula;
- (float)ibuContribution;
- (float)tinsethUtilizationForGravity:(float)gravity;
- (float)ragerUtilization;
- (float)alphaAcidUnits;

#pragma mark - OBIngredientAddition Protocol

- (void)removeFromRecipe;

@end
