//
//  OBMaltViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBPickerObserver.h"
#import "OBBrewController.h"

@class OBRecipe;

@interface OBMaltAdditionViewController : UIViewController <OBBrewController>

@property (nonatomic, strong) OBRecipe *recipe;

@end
