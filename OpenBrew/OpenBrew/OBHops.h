//
//  OBHops.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBHops : NSObject

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *description;

@property (assign, nonatomic) float alphaAcidPercent;
@property (assign, nonatomic) int boilTimeInMinutes;
@property (assign, nonatomic) int quantityInOunces;

- (float)ibuContributionWithBoilSize:(float)gallons andGravity:(float)gravity;

@end
