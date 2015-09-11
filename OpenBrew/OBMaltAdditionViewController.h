//
//  OBMaltViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBBrewController.h"
#import "GAITrackedViewController.h"

@class OBRecipe, OBBrewery, OBTableViewPlaceholderLabel, OBIngredientGauge, OBMaltAdditionTableViewDelegate;

@interface OBMaltAdditionViewController : GAITrackedViewController <OBBrewController>

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic) OBBrewery *brewery;

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) OBTableViewPlaceholderLabel *placeholderText;
@property (nonatomic) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic) OBMaltAdditionTableViewDelegate *tableViewDelegate;

@property (nonatomic) IBOutlet UIBarButtonItem *infoButton;

@end
