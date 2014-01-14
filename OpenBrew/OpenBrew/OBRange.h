//
//  OBRange.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/14/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBRange : NSObject

@property (assign, nonatomic) float lowEnd;
@property (assign, nonatomic) float highEnd;

- (id)initWithLowEnd:(float)lowEnd andHighEnd:(float)highEnd;

@end
