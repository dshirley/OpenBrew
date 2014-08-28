//
//  OBHopAddition.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBHops, OBRecipe;

@interface OBHopAddition : NSManagedObject

@property (nonatomic, retain) NSNumber * alphaAcidPercent;
@property (nonatomic, retain) NSNumber * boilTimeInMinutes;
@property (nonatomic, retain) NSNumber * quantityInOunces;
@property (nonatomic, retain) NSNumber *displayOrder;
@property (nonatomic, retain) OBHops *hops;
@property (nonatomic, retain) OBRecipe *recipe;

- (id)initWithHopVariety:(OBHops *)hopVariety andRecipe:(OBRecipe *)recipe;

- (float)ibuContributionWithBoilSize:(float)gallons andGravity:(float)gravity;
- (float)ibuContribution;
- (float)utilizationForGravity:(float)gravity;
- (float)alphaAcidUnits;

- (NSInteger)percentOfIBUs;

@end
