//
//  OBHops.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBHops : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) float defaultAlphaAcidPercent;

@end


@interface OBHopAddition : NSManagedObject

@property (nonatomic, assign) float alphaAcidPercent;
@property (nonatomic, assign) int boilTimeInMinutes;
@property (assign, nonatomic) float quantityInOunces;

- (float)ibuContributionWithBoilSize:(float)gallons andGravity:(float)gravity;
- (float)utilizationForGravity:(float)gravity;
- (float)alphaAcidUnits;

@end
