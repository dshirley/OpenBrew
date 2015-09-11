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

@class OBRecipe, OBIngredientGauge;

@interface OBYeastAdditionViewController : GAITrackedViewController <OBBrewController>

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (void)viewDidLoad;

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
