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
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

// Google Analytics constants
static NSString *const OBGAScreenName = @"Recipe List Screen";

static NSString *const ADD_RECIPE_SEGUE = @"addRecipe";
static NSString *const SELECT_RECIPE_SEGUE = @"selectRecipe";

@interface OBRecipeViewController ()
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *placeholderText;

// Variables for tracking first interaction time with Google Analytics
@property (nonatomic, assign) CFAbsoluteTime loadTime;
@property (nonatomic, assign) BOOL firstInteractionComplete;
@end

@implementation OBRecipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      self.firstInteractionComplete = NO;
    }
    return self;
}

#pragma mark UIViewController Override Methods

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.screenName = OBGAScreenName;

  if (!self.firstInteractionComplete) {
    self.loadTime = CFAbsoluteTimeGetCurrent();
  }

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  OBRecipeNavigationController *nav = (OBRecipeNavigationController *) [self navigationController];
  NSManagedObjectContext *ctx = [nav managedContext];
  NSString *segueId = [segue identifier];
  OBRecipe *recipe = nil;

  if (!self.firstInteractionComplete) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    CFTimeInterval timeDelta = CFAbsoluteTimeGetCurrent() - self.loadTime;

    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:OBGAScreenName
                                                         interval:@((NSUInteger)(timeDelta * 1000))
                                                             name:@"First Interaction"
                                                            label:segueId] build]];

    self.firstInteractionComplete = YES;
  }

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


#pragma mark UITableView Utility Methods

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
}

- (void)switchToNonEmptyTableViewMode
{
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

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                          action:@"Delete"
                                                           label:nil
                                                           value:nil] build]];
  }
}

@end
