//
//  OBRecipeListViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSettings.h"
#import "GAITrackedViewController.h"
#import "OBPlaceholderView.h"
#import "OBRecipeListViewController.h"
#import "OBCalculationsViewController.h"

@interface OBMainViewController : GAITrackedViewController <UITableViewDelegate>

@property (nonatomic) IBOutlet UIBarButtonItem *addRecipeButton;
@property (nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic) OBSettings *settings;

@property (nonatomic) UIPageViewController *pageViewController;

@property (nonatomic) NSManagedObjectContext *moc;

@property (nonatomic, readonly) OBRecipeListViewController *recipeListViewControler;
@property (nonatomic, readonly) OBCalculationsViewController *calculationsViewController;

@end
