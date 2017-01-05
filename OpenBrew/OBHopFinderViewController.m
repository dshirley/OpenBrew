//
//  OBIngredientFinderViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopFinderViewController.h"
#import "OBIngredientTableViewDataSource.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "OBHopAddition.h"
#import "OBHops.h"
#import "OBRecipe.h"
#import "Crittercism+NSErrorLogging.h"

// Google Analytics event category
static NSString* const OBGAScreenName = @"Hop Finder Screen";

@interface OBHopFinderViewController ()

@property (nonatomic) OBIngredientTableViewDataSource *tableViewDataSource;

// This allows Google Analytics to track the amount of time taken to find an ingredient
@property (nonatomic, assign) CFAbsoluteTime startTime;

@end

@implementation OBHopFinderViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
  self.searchController.searchResultsUpdater = self;
  self.searchController.dimsBackgroundDuringPresentation = NO;

  self.tableViewDataSource = [[OBIngredientTableViewDataSource alloc]
                              initIngredientEntityName:@"Hops"
                              andManagedObjectContext:self.recipe.managedObjectContext];

  self.tableView.dataSource = self.tableViewDataSource;

  self.tableView.tableHeaderView = self.searchController.searchBar;
  self.definesPresentationContext = YES;

  // This works around an issue where the UISearchController produces a warning message during deallocation
  [self.searchController loadViewIfNeeded];

  [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.screenName = OBGAScreenName;
  self.startTime = CFAbsoluteTimeGetCurrent();
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if (self.searchController.isActive) {
    [self.navigationController popViewControllerAnimated:YES];
  }
  
  if ([[segue identifier] isEqualToString:@"IngredientSelected"] && sender) {
    // The user chose an ingredient to add to a recipe
    // Set the selectedIngredient so that we can add it when the segue completes

    NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
    OBHops *selectedHops = [self.tableViewDataSource ingredientAtIndexPath:cellIndex];


    OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:selectedHops
                                                                 andRecipe:self.recipe];

    [self.recipe addHopAdditionsObject:hopAddition];

    NSError *error = nil;
    [self.recipe.managedObjectContext save:&error];
    CRITTERCISM_LOG_ERROR(error);
  }
}

- (void)applyFilter:(NSString *)searchText
{
  if (searchText.length) {
    self.tableViewDataSource.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
  } else {
    self.tableViewDataSource.predicate = nil;
  }

  [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
  [self applyFilter:searchController.searchBar.text];
}

@end

