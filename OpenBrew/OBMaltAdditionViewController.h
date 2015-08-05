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

@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, strong) OBBrewery *brewery;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) OBTableViewPlaceholderLabel *placeholderText;
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, strong) OBMaltAdditionTableViewDelegate *tableViewDelegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;

@end
