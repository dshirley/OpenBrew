//
//  OBIngredientFinderViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class OBIngredientTableViewDataSource;

@interface OBHopFinderViewController : GAITrackedViewController

@property (nonatomic, strong) id selectedIngredient;
@property (nonatomic, strong) OBIngredientTableViewDataSource *tableViewDataSource;

@end
