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

@property (nonatomic, retain) OBMalt *malt;
@property (nonatomic, retain) OBRecipe *recipe;

@property (nonatomic, retain) NSNumber * lovibond;
@property (nonatomic, retain) NSNumber * extractPotential;
@property (nonatomic, retain) NSNumber * quantityInPounds;

- (id)initWithMalt:(OBMalt *)malt;

- (float)gravityUnitsWithEfficiency:(float)efficiency;

- (NSString *)name;

- (NSString *)quantityText;

@end
