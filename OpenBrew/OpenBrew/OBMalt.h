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

@property (assign, nonatomic) int quantity;
@property (assign, nonatomic) int maxGravityUnits;
@property (assign, nonatomic) int lovibond;

- (int)contributedGravityUnitsWithEfficiency:(float)efficiency;

@end
