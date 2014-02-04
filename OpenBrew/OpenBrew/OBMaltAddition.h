//
//  OBMaltAddition.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBMalt, OBRecipe;

@interface OBMaltAddition : NSManagedObject

@property (nonatomic, retain) NSNumber * lovibond;
@property (nonatomic, retain) NSNumber * extractPotential;
@property (nonatomic, retain) NSNumber * quantityInPounds;
@property (nonatomic, retain) OBMalt *malt;
@property (nonatomic, retain) OBRecipe *recipe;

- (float)gravityUnitsWithEfficiency:(float)efficiency;

@end
