//
//  OBYeastAddition.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OBYeast.h"

@class OBRecipe;

@interface OBYeastAddition : OBYeast

@property (nonatomic) NSNumber *quantity;
@property (nonatomic) OBRecipe *recipe;

- (id)initWithYeast:(OBYeast *)yeast andRecipe:(OBRecipe *)recipe;

@end
