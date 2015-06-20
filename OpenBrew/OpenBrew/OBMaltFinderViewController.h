//
//  OBMaltFinderViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class OBMalt;
@class OBIngredientTableViewDataSource;

@interface OBMaltFinderViewController : GAITrackedViewController

@property (nonatomic, strong) OBMalt *selectedIngredient;
@property (nonatomic, strong) OBIngredientTableViewDataSource *tableViewDataSource;

@end
