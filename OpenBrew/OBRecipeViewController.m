//
//  OBRecipeViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipeViewController.h"
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

@property (nonatomic) UIView *placeholderText;

// Variables for tracking first interaction time with Google Analytics
@property (nonatomic, assign) CFAbsoluteTime loadTime;

@property (nonatomic, assign) BOOL firstInteractionComplete;

@end

@implementation OBRecipeViewController

#pragma mark UIViewController Override Methods

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.firstInteractionComplete = NO;
  self.loadTime = CFAbsoluteTimeGetCurrent();
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.screenName = OBGAScreenName;

  if ([self tableViewIsEmpty]) {
    [self switchToEmptyTableViewMode];
  } else {
    [self switchToNonEmptyTableViewMode];
  }

  [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
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
    recipe = [[OBRecipe alloc] initWithContext:self.moc];
    recipe.name = @"New Recipe";

    NSError *err = nil;
    [self.moc save:&err];
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
  return ([self recipeData].count == 0);
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

- (NSArray *)recipeData
{
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"Recipe"
                                            inManagedObjectContext:self.moc];

  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                 ascending:YES];

  [request setSortDescriptors:@[sortDescriptor]];

  NSError *error = nil;
  NSArray *array = [self.moc executeFetchRequest:request error:&error];

  if (error) {
    CRITTERCISM_LOG_ERROR(error);
    array = [NSArray array];
  }

  return array;
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
    [self.moc deleteObject:recipeToRemove];

    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];

    NSError *error = nil;
    [self.moc save:&error];
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
