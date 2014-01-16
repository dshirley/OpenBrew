//
//  OBMalt.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBMalt : NSObject

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *description;

@property (assign, nonatomic) float quantityInPounds;
@property (assign, nonatomic) float maxGravityUnitsPerPound;
@property (assign, nonatomic) int lovibond;

- (id)initWithName:(NSString *)name
    andDescription:(NSString *)description
       andQuantity:(float)quantityInPounds
   andGravityUnits:(float)maxGravityUnitPerPound
       andLovibond:(int)lovibond;

- (float)contributedGravityUnitsWithEfficiency:(float)efficiency;

@end
