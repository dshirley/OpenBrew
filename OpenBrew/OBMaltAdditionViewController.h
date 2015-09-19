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
#import "OBGaugePageViewControllerDataSource.h"
#import "OBPlaceholderView.h"

@class OBRecipe, OBSettings, OBMaltAdditionTableViewDelegate;

@interface OBMaltAdditionViewController : GAITrackedViewController <OBBrewController>

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic) OBSettings *settings;

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet OBPlaceholderView *placeholderView;

@property (nonatomic) OBMaltAdditionTableViewDelegate *tableViewDelegate;
@property (nonatomic) OBGaugePageViewControllerDataSource *pageViewControllerDataSource;

@property (nonatomic) IBOutlet UIBarButtonItem *infoButton;

@end
