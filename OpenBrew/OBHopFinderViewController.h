//
//  OBIngredientFinderViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "GAITrackedViewController.h"

@class OBRecipe;

@interface OBHopFinderViewController : GAITrackedViewController<UISearchResultsUpdating>

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UISearchController *searchController;

- (void)viewDidLoad;

- (void)viewWillAppear:(BOOL)animated;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

- (void)applyFilter:(NSString *)searchText;

@end

@interface OBHopFinderViewController(UISearchResultsUpdating)

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController;

@end
