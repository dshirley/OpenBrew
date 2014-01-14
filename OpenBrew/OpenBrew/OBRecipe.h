//
//  OBRecipe.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBStyle.h"
#import "OBYeast.h"
#import "OBMalt.h"
#import "OBHops.h"

@interface OBRecipe : NSObject

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) OBStyle *style;
@property (retain, nonatomic) OBYeast *yeast;
@property (assign, nonatomic) int batchSizeInGallons;

- (NSArray *)malts;
- (NSArray *)hops;

- (void)addMalt:(OBMalt *)malt;
- (void)addHops:(OBHops *)hops;

- (float)boilSizeInGallons;
- (float)boilGravity;
- (float)gravityUnits;
- (float)originalGravity;
- (float)IBUs;
- (float)alcoholByVolume;

- (void)save;

@end
