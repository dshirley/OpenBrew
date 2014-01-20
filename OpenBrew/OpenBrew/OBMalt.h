//
//  OBMalt.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBMalt : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) float defaultMaxYield;
@property (nonatomic, assign) float defaultLovibond;

@end


@interface OBMaltAddition : NSManagedObject

@property (nonatomic, strong) OBMalt *malt;
@property (nonatomic, assign) float quantityInPounds;
@property (nonatomic, assign) float maxYield;
@property (nonatomic, assign) int lovibond;


- (float)gravityUnitsWithEfficiency:(float)efficiency;

@end
