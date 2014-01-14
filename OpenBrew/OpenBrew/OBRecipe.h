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

@interface OBRecipe : NSObject

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) OBStyle *style;
@property (retain, nonatomic) OBYeast *yeast;

- (float)originalGravity;
- (float)IBUs;
- (float)alcoholByVolume;

- (void)save;

@end
