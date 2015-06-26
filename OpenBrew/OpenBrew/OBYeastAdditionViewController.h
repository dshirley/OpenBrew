//
//  OBYeastAdditionViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 6/25/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBBrewController.h"
#import "GAITrackedViewController.h"

@class OBRecipe;

@interface OBYeastAdditionViewController : GAITrackedViewController <OBBrewController>

@property (nonatomic, strong) OBRecipe *recipe;

@end
