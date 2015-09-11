//
//  OBBatchSizeViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/20/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBBrewController.h"
#import "GAITrackedViewController.h"

@class OBRecipe;

@interface OBBatchSizeViewController : GAITrackedViewController <OBBrewController>
@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic) IBOutlet UITableView *tableView;

- (void)viewDidLoad;

@end
