//
//  OBMaltFinderViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "GAITrackedViewController.h"

@class OBRecipe;

@interface OBMaltFinderViewController : GAITrackedViewController

@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

- (void)viewDidLoad;

- (void)viewWillAppear:(BOOL)animated;

- (IBAction)applyMaltTypeFilter:(UISegmentedControl *)sender;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;


@end
