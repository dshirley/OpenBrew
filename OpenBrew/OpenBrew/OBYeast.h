//
//  OBYeast.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRange.h"

@interface OBYeast : NSObject

@property (retain, readonly, nonatomic) NSString *name;
@property (retain, readonly, nonatomic) NSString *company;
@property (retain, readonly, nonatomic) NSString *description;
@property (retain, readonly, nonatomic) NSURL *referenceLink;

@property (assign, readonly, nonatomic) OBRange *attenuationRange;

- (float)estimatedAttenuationAsDecimal;

@end
