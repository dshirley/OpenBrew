//
//  OBRecipeOverviewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/26/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRecipe.h"

@interface OBRecipeOverviewController : UITableViewController

@property (nonatomic, strong) OBRecipe *recipe;

- (void)reloadData;

@end
