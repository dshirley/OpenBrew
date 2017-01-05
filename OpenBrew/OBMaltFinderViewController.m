//
//  OBMaltFinderViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltFinderViewController.h"
#import "OBIngredientTableViewDataSource.h"
#import "OBKvoUtils.h"
#import "OBMalt.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "OBMaltAddition.h"
#import "OBRecipe.h"
#import "Crittercism+NSErrorLogging.h"

// Google Analytics event category
static NSString* const OBGAScreenName = @"Malt Finder Screen";

@interface OBMaltFinderViewController ()

@property (nonatomic) OBIngredientTableViewDataSource *tableViewDataSource;

// This allows Google Analytics to track the amount of time taken to find an ingredient
@property (nonatomic, assign) CFAbsoluteTime startTime;

@end

@implementation OBMaltFinderViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
  self.searchController.searchResultsUpdater = self;
  self.searchController.dimsBackgroundDuringPresentation = NO;

  self.tableViewDataSource = [[OBIngredientTableViewDataSource alloc]
                              initIngredientEntityName:@"Malt"
                              andManagedObjectContext:self.recipe.managedObjectContext];

  self.tableView.dataSource = self.tableViewDataSource;
  self.tableView.tableHeaderView = self.searchController.searchBar;
  self.definesPresentationContext = YES;

  [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.screenName = OBGAScreenName;
  self.startTime = CFAbsoluteTimeGetCurrent();
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if (self.searchController.isActive) {
    [self.navigationController popViewControllerAnimated:YES];
  }

  if ([[segue identifier] isEqualToString:@"IngredientSelected"] && sender) {
    // The user chose an ingredient to add to a recipe
    // Set the selectedIngredient so that we can add it when the segue completes

    NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
    OBMalt *selectedMalt = [self.tableViewDataSource ingredientAtIndexPath:cellIndex];

    // Create the malt addition and add it to the recipe in one go
    (void)[[OBMaltAddition alloc] initWithMalt:selectedMalt andRecipe:self.recipe];

    NSError *error = nil;
    [self.recipe.managedObjectContext save:&error];
    CRITTERCISM_LOG_ERROR(error);
  }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
  [self applyFilter:searchController.searchBar.text];
}

@end

