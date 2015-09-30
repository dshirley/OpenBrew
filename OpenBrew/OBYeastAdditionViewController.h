//
//  OBYeastAdditionViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 6/25/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBBrewController.h"
#import "GAITrackedViewController.h"
#import "OBGaugePageViewControllerDataSource.h"
#import "OBSegmentedControl.h"

@class OBRecipe;

@interface OBYeastAdditionViewController : GAITrackedViewController <OBBrewController, OBSegmentedControlDelegate>

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic) OBSettings *settings;

@property (nonatomic) OBGaugePageViewControllerDataSource *pageViewControllerDataSource;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet OBSegmentedControl *segmentedControl;

- (void)viewDidLoad;

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
