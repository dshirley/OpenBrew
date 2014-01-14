//
//  OBBrewHouseSettings.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/14/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBBrewHouseSettings : NSObject
@property (assign, nonatomic) float mashExtractionEfficiency;

+ (OBBrewHouseSettings *)instance;
@end
