//
//  OBRecipeViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipeViewController.h"
#import "OBRecipeNavigationController.h"
#import "OBRecipeOverviewController.h"
#import "OBBrewery.h"
#import "Crittercism+NSErrorLogging.h"
#import "OBTableViewPlaceholderLabel.h"

static NSString *const ADD_RECIPE_SEGUE = @"addRecipe";
static NSString *const SELECT_RECIPE_SEGUE = @"selectRecipe";

@interface OBRecipeViewController ()
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *placeholderText;
@end

@implementation OBRecipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.screenName = @"Recipe List Screen";

  if ([self tableViewIsEmpty]) {
    [self switchToEmptyTableViewMode];
  } else {
    [self switchToNonEmptyTableViewMode];
  }

  if (!self.isMovingToParentViewController) {
    // A sub-view controller is being popped
    [self.tableView reloadData];
  }
}

- (BOOL)tableViewIsEmpty
{
  return (self.brewery.recipes.count == 0);
}

// Changes the look and feel to have placeholder text that makes it clear
// there are no recipes available.  Also remove the unnecessary "edit" button
// to eliminate confusion.
- (void)switchToEmptyTableViewMode
{
  if (!self.placeholderText) {
    self.placeholderText = [[OBTableViewPlaceholderLabel alloc]
                            initWithFrame:self.tableView.frame
                            andText:@"No Recipes"];
  }

  self.tableView.tableFooterView = self.placeholderText;
  self.navigationItem.rightBarButtonItem = nil;
}

- (void)switchToNonEmptyTableViewMode
{
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.tableView.tableFooterView = nil;
}

- (OBBrewery *)brewery
{
  OBRecipeNavigationController *nav = nil;
  nav =(OBRecipeNavigationController *) [self navigationController];
  return nav.brewery;
}

- (NSArray *)recipeData
{
  NSSortDescriptor *sortByDisplayOrder;

  sortByDisplayOrder = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                   ascending:YES];

  NSArray *sortSpecification = @[ sortByDisplayOrder ];
  OBBrewery *brewery = [self brewery];

  return [brewery.recipes sortedArrayUsingDescriptors:sortSpecification];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[self recipeData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OBRecipeCell"
                                                          forIndexPath:indexPath];

  NSArray *recipes = [self recipeData];
  OBRecipe *recipe = recipes[indexPath.row];

  cell.textLabel.text = [NSString stringWithFormat:@"%@", recipe.name];
  
  return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  OBRecipeNavigationController *nav = (OBRecipeNavigationController *) [self navigationController];
  NSManagedObjectContext *ctx = [nav managedContext];
  NSString *segueId = [segue identifier];
  OBRecipe *recipe = nil;

  if ([segueId isEqualToString:ADD_RECIPE_SEGUE]) {
    OBBrewery *brewery = [self brewery];

    recipe = [[OBRecipe alloc] initWithContext:ctx];
    recipe.name = @"New Recipe";

    [brewery addRecipesObject:recipe];
    recipe.brewery = brewery;

    NSError *err = nil;
    [ctx save:&err];
    CRITTERCISM_LOG_ERROR(err);

  } else if ([segueId isEqualToString:SELECT_RECIPE_SEGUE]) {
    NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
    recipe = [self recipeData][cellIndex.row];
  }

  assert(recipe);
  id nextController = [segue destinationViewController];
  [nextController setRecipe:recipe];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    OBRecipe *recipeToRemove = [self recipeData][indexPath.row];
    [self.brewery removeRecipesObject:recipeToRemove];

    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];

    NSError *error = nil;
    [self.brewery.managedObjectContext save:&error];
    CRITTERCISM_LOG_ERROR(error);

    if ([self tableViewIsEmpty]) {
      [self switchToEmptyTableViewMode];
    }
  }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
  [super setEditing:editing animated:animated];

  [self.tableView setEditing:editing animated:animated];
}

@end
