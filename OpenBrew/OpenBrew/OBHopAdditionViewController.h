//
//  OBHopAdditionViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBDrawerTableViewDelegate.h"
#import "OBBrewController.h"
#import "GAITrackedViewController.h"

@interface OBHopAdditionViewController : GAITrackedViewController <OBBrewController>
@property (nonatomic, retain) OBRecipe *recipe;
@end
