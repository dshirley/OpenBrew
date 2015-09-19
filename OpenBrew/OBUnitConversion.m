//
//  OBUnitConversion.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/19/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBUnitConversion.h"

// TODO: make this more precise
#define GRAMS_PER_OUNCE 28.0

float gramsToOunces(float grams)
{
  return grams / GRAMS_PER_OUNCE;
}

float ouncesToGrams(float ounces)
{
  return ounces * GRAMS_PER_OUNCE;
}
