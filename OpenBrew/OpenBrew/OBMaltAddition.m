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
@dynamic lovibond;
@dynamic extractPotential;
@dynamic quantityInPounds;
@dynamic malt;
@dynamic recipe;

- (id)initWithMalt:(OBMalt *)malt andRecipe:(OBRecipe *)recipe {
  NSManagedObjectContext *ctx = [malt managedObjectContext];
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"MaltAddition"
                                          inManagedObjectContext:ctx];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:ctx]) {
    self.malt = malt;
    self.quantityInPounds = @0;
    self.extractPotential = [malt defaultExtractPotential];
    self.lovibond = [malt defaultLovibond];
    self.recipe = recipe;
  }

  return self;
}

- (float)gravityUnitsWithEfficiency:(float)efficiency {
  float potential = [self.extractPotential floatValue];
  float pounds = [self.quantityInPounds floatValue];

  return 1000 * (potential - 1) * pounds * efficiency;
}

- (NSString *)name {
  return self.malt.name;
}

- (NSString *)quantityText {
  // TODO: this impacts UI formatting, which mixes up the model and the view
  // consider putting this somewhere else

  double pounds = trunc([self.quantityInPounds doubleValue]);
  double ounces = [self.quantityInPounds doubleValue] - pounds;

  if (pounds == 0 && (ounces * 1000 < 1)) {
    return @"0lb";
  }

  NSString *poundsString = @"";
  NSString *ouncesString = @"";

  if (pounds > 0) {
    // Only display the pounds portion if there's at least one pound
    poundsString = [NSString stringWithFormat:@"%dlb", (int)pounds];
  }

  if ((ounces * 16) > 0) {
    ouncesString = [NSString stringWithFormat:@" %doz", (int) (ounces * 16)];
  } else if (pounds == 0) {
    // Only display ounce decimals if there's less than an ounce of this ingredient
    ouncesString = [NSString stringWithFormat:@" %.3foz", (float) ounces];
  }

  return [poundsString stringByAppendingString:ouncesString];
}

@end
