//
//  OBIngredientFinderViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class OBHops;
@class OBRecipe;
@class OBIngredientTableViewDataSource;

@interface OBHopFinderViewController : GAITrackedViewController

@property (nonatomic, strong) OBRecipe *recipe;

@end
