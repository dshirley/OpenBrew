//
//  OBMaltAddition.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltAddition.h"
#import "OBMalt.h"
#import "OBRecipe.h"

#import <math.h>

@implementation OBMaltAddition

@dynamic displayOrder;
@dynamic quantityInPounds;
@dynamic recipe;

- (id)initWithMalt:(OBMalt *)malt andRecipe:(OBRecipe *)recipe {
  NSManagedObjectContext *ctx = [malt managedObjectContext];
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"MaltAddition"
                                          inManagedObjectContext:ctx];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:ctx]) {
    self.name = malt.name;
    self.type = malt.type;
    self.quantityInPounds = @0;
    self.extractPotential = malt.extractPotential;
    self.lovibond = malt.lovibond;
    self.recipe = recipe;
  }

  return self;
}

- (float)gravityUnitsWithEfficiency:(float)efficiency {
  float potential = [self.extractPotential floatValue];
  float pounds = [self.quantityInPounds floatValue];

  if ([self isExtract] || [self isSugar]) {
    efficiency = 1.0;
  }

  return 1000 * (potential - 1) * pounds * efficiency;
}

- (NSString *)quantityText {
  double pounds = trunc([self.quantityInPounds doubleValue]);
  double ounces = ([self.quantityInPounds doubleValue] - pounds) * 16;

  if (pounds == 0 && (ounces * 1000 < 1)) {
    return @"0lb";
  }

  NSString *poundsString = @"";
  NSString *ouncesString = @"";

  if (pounds > 0) {
    // Only display the pounds portion if there's at least one pound
    poundsString = [NSString stringWithFormat:@"%dlb", (int)pounds];
  }

  if (ounces >= 1) {
    ouncesString = [NSString stringWithFormat:@" %doz", (int) ounces];
  } else if (pounds == 0) {
    // Only display ounce decimals if there's less than an ounce of this ingredient
    ouncesString = [NSString stringWithFormat:@" %.3foz", (float) ounces];
  }

  NSString *combined = [poundsString stringByAppendingString:ouncesString];
  return [combined stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (float)maltColorUnitsForBoilSize:(float)boilSize
{
  float lovibond = [[self lovibond] floatValue];
  float quantityInPounds = [[self quantityInPounds] floatValue];

  if ([self isExtract]) {
    // Extract is a concentrated form of grain.  We need to "reinflate" it in order
    // to get a realistic color reading.  0.7 is essentially the extract : grain
    // concentrate ratio. I noticed this was necessary when the Munich Dunkel
    // test for color was failing for extract, but not for all grain.
    quantityInPounds /= 0.70;
  }

  return (lovibond * quantityInPounds) / boilSize;
}

- (NSInteger)percentOfGravity
{
  return [self.recipe percentTotalGravityOfMaltAddition:self];
}

#pragma mark - OBIngredientAddition Protocol

- (void)removeFromRecipe
{
  [self.recipe removeMaltAdditionsObject:self];
  self.recipe = nil;
}

@end
