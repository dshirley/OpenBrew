//
//  OBHopAddition.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopAddition.h"
#import "OBHops.h"
#import "OBRecipe.h"

@implementation OBHopAddition

@dynamic name;
@dynamic alphaAcidPercent;
@dynamic boilTimeInMinutes;
@dynamic quantityInOunces;
@dynamic recipe;
@dynamic displayOrder;

// Used to convert oz/gallon to gram/liter
#define IMPERIAL_TO_METRIC_CONST 74.891

- (id)initWithHopVariety:(OBHops *)hopVariety andRecipe:(OBRecipe *)recipe
{
  NSManagedObjectContext *ctx = [hopVariety managedObjectContext];
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"HopAddition"
                                          inManagedObjectContext:ctx];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:ctx]) {
    self.name = hopVariety.name;
    self.quantityInOunces = @0;
    self.boilTimeInMinutes = @0;
    self.alphaAcidPercent = hopVariety.alphaAcidPercent;
    self.recipe = recipe;
  }

  return self;
}

- (float)ibusForRecipeVolume:(float)gallons boilGravity:(float)gravity ibuFormula:(OBIbuFormula)formula {
  if (formula == OBIbuFormulaTinseth) {
    return [self tinsethIbusForRecipeVolume:gallons boilGravity:gravity];
  } else {
    return [self ragerIbusForRecipeVolume:gallons boilGravity:gravity];
  }
}

- (float)ragerIbusForRecipeVolume:(float)gallons boilGravity:(float)gravity
{
  // From http://rhbc.co/wiki/calculating-ibus
  float alphaAcidUnits = [self alphaAcidUnits];
  float utilization = [self ragerUtilization];
  float gravityAdjustment = 0;

  if (gravity > 1.050) {
    gravityAdjustment = (gravity - 1.050) / 0.2;
  }

  return (alphaAcidUnits * utilization * IMPERIAL_TO_METRIC_CONST) / (gallons * (1 + gravityAdjustment));
}

- (float)ragerUtilization
{
  return (18.11 + 13.86 * tanh(([self.boilTimeInMinutes floatValue] - 31.32) / 18.27)) / 100.0;
}

- (float)tinsethIbusForRecipeVolume:(float)gallons boilGravity:(float)gravity
{
  // Using John Palmer's formula from How To Brew
  // http://www.howtobrew.com/section1/chapter5-5.html

  float alphaAcidUnits = [self alphaAcidUnits];
  float utilization = [self tinsethUtilizationForGravity:gravity];

  return (alphaAcidUnits * utilization * IMPERIAL_TO_METRIC_CONST) / gallons;
}

- (float)ibuContribution
{
  return [self.recipe ibusForHopAddition:self];
}

- (float)alphaAcidUnits {
  return [[self alphaAcidPercent] floatValue] * [[self quantityInOunces] floatValue];
}

- (float)tinsethUtilizationForGravity:(float)gravity {
  // Tinseth formula:
  // (1.65 * 0.000125^(wort gravity - 1)) * (1 - e^(-0.04 * time in mins) )
  
  float gravityFactor = 1.65 * powf(0.000125, gravity - 1);
  float timeFactor = (1 - powf(M_E, -.04 * [[self boilTimeInMinutes] floatValue])) / 4.15;
  
  return gravityFactor * timeFactor;
}

#pragma mark - OBIngredientAddition Protocol

- (void)removeFromRecipe
{
  [self.recipe removeHopAdditionsObject:self];
  self.recipe = nil;
}

@end
