//
//  OBIngredientFinderViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "GAITrackedViewController.h"

@class OBRecipe;

@interface OBHopFinderViewController : GAITrackedViewController

@property (nonatomic, strong) OBRecipe *recipe;

@end
