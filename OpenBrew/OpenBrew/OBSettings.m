//
//  OBSettings.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBSettings.h"

static NSString *const OBIbuFormulaKey = @"OBSettingsIbuFormula";
static NSString *const OBPreBoilSizeKey = @"OBSettingsPreBoilSize";
static NSString *const OBPostBoilSizeKey = @"OBSettingsPostBoilSize";

@implementation OBSettings

// FIXME:  all of these need to have default values when the keys are not set

+ (NSNumber *)defaultPreBoilSize;
{
  NSNumber *preBoilSize = [[NSUserDefaults standardUserDefaults] valueForKey:OBPreBoilSizeKey];
  if (!preBoilSize) {
    preBoilSize = @(7.0);
  }

  return preBoilSize;
}

+ (void)setDefaultPreBoilSize:(NSNumber *)preBoilSize;
{
  [[NSUserDefaults standardUserDefaults] setValue:preBoilSize forKey:OBPreBoilSizeKey];
}

+ (NSNumber *)defaultPostBoilSize;
{
  NSNumber *postBoilSize = [[NSUserDefaults standardUserDefaults] valueForKey:OBPostBoilSizeKey];
  if (!postBoilSize) {
    return @(6.0);
  }

  return postBoilSize;
}

+ (void)setDefaultPostBoilSize:(NSNumber *)postBoilSize
{
  [[NSUserDefaults standardUserDefaults] setValue:postBoilSize forKey:OBPostBoilSizeKey];
}

+ (OBIbuFormula)ibuFormula
{
  NSNumber *ibuFormula = [[NSUserDefaults standardUserDefaults] valueForKey:OBIbuFormulaKey];
  if (!ibuFormula) {
    return OBIbuFormulaTinseth;
  }

  return [ibuFormula integerValue];
}

+ (void)setIbuFormula:(OBIbuFormula)formula
{
  [[NSUserDefaults standardUserDefaults] setValue:@(formula) forKey:OBIbuFormulaKey];
}

@end
