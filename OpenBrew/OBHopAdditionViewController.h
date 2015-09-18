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

@class OBRecipe, OBSettings, OBTableViewPlaceholderLabel, OBGaugePageViewControllerDataSource, OBHopAdditionTableViewDelegate;

@interface OBHopAdditionViewController : GAITrackedViewController <OBBrewController>

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic) OBSettings *settings;

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) OBTableViewPlaceholderLabel *placeholderText;
@property (nonatomic) OBGaugePageViewControllerDataSource *pageViewControllerDataSource;
@property (nonatomic) OBHopAdditionTableViewDelegate *tableViewDelegate;

@property (nonatomic) IBOutlet UIBarButtonItem *infoButton;

@end
