//
//  OBYeastAddition.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBRecipe, OBYeast;

@interface OBYeastAddition : NSManagedObject

@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) OBRecipe *recipe;
@property (nonatomic, retain) OBYeast *yeast;

- (id)initWithYeast:(OBYeast *)yeast andRecipe:(OBRecipe *)recipe;

@end
