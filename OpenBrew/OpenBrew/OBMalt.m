//
//  OBMalt.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMalt.h"

@implementation OBMalt

- (id)initWithName:(NSString *)name
    andDescription:(NSString *)description
       andQuantity:(float)quantityInPounds
   andGravityUnits:(float)maxGravityUnitPerPound
       andLovibond:(int)lovibond {

  if (self) {
    _name = name;
    _description = description;
    _quantityInPounds = quantityInPounds;
    _maxGravityUnitsPerPound = maxGravityUnitPerPound;
    _lovibond = lovibond;
  }

  return self;
}

- (float)contributedGravityUnitsWithEfficiency:(float)efficiency {
  return _maxGravityUnitsPerPound * _quantityInPounds * efficiency;
}


@end
