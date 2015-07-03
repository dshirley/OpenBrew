//
//  OBSettings.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBSettings.h"

static NSString *const OBIbuFormulaKey = @"OBSettingsIbuFormula";

@implementation OBSettings

+ (OBIbuFormula)ibuFormula
{
  return [[[NSUserDefaults standardUserDefaults] valueForKey:OBIbuFormulaKey] integerValue];
}

+ (void)setIbuFormula:(OBIbuFormula)formula
{
  [[NSUserDefaults standardUserDefaults] setValue:@(formula) forKey:OBIbuFormulaKey];
}

@end
