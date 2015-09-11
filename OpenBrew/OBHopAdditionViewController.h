//
//  OBHopAdditionViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBBrewController.h"
#import "GAITrackedViewController.h"

@class OBRecipe, OBBrewery, OBTableViewPlaceholderLabel, OBIngredientGauge, OBHopAdditionTableViewDelegate;

@interface OBHopAdditionViewController : GAITrackedViewController <OBBrewController>

@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, strong) OBBrewery *brewery;

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) OBTableViewPlaceholderLabel *placeholderText;
@property (nonatomic) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, strong) OBHopAdditionTableViewDelegate *tableViewDelegate;

@property (nonatomic) IBOutlet UIBarButtonItem *infoButton;

@end
