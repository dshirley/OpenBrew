//
//  OBSettings.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBHopAddition.h"

@interface OBGlobalSettings : NSObject

+ (NSNumber *)defaultPreBoilSize;

+ (void)setDefaultPreBoilSize:(NSNumber *)preBoilSize;

+ (NSNumber *)defaultPostBoilSize;

+ (void)setDefaultPostBoilSize:(NSNumber *)postBoilSize;

@end
