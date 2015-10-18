//
//  OBRecipeListViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/17/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBRecipeListViewController.h"
#import "Crittercism+NSErrorLogging.h"
#import "OBRecipeTableViewCell.h"
#import "OBRecipe.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

static NSString *const OBGAScreenName = @"Recipe List Screen";

static NSString *const SELECT_RECIPE_SEGUE = @"selectRecipe";

@implementation OBRecipeListViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.placeholderView.messageLabel.text = @"No Recipes";
  self.placeholderView.instructionsLabel.text = @"Tap the '+' button to create a recipe.";

  NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Recipe"];
  request.fetchBatchSize = 20;
  request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name"
                                                          ascending:YES]];

  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                      managedObjectContext:self.managedObjectContext
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:@"recipes"];

  self.fetchedResultsController.delegate = self;

  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    CRITTERCISM_LOG_ERROR(error);
  }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  NSString *segueId = [segue identifier];
  OBRecipe *recipe = nil;

  if ([segueId isEqualToString:SELECT_RECIPE_SEGUE]) {
    NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
    recipe = [self.fetchedResultsController objectAtIndexPath:cellIndex];
    NSAssert(recipe, @"Recipe was nil for cell %@", cellIndex);
  } else {
    NSAssert(NO, @"Unexpected segue: %@", segueId);
  }

  id nextController = [segue destinationViewController];
  [nextController setRecipe:recipe];
  [nextController setSettings:self.settings];
}


#pragma mark - Utility Methods

- (void)configureCell:(OBRecipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  OBRecipe *recipe = [self.fetchedResultsController objectAtIndexPath:indexPath];

  cell.recipeName.text = recipe.name;
  cell.colorView.colorInSrm = [recipe colorInSRM];
}

- (BOOL)tableViewIsEmpty
{
  return 0 == [self.fetchedResultsController.sections[0] numberOfObjects];
}

// Changes the look and feel to have placeholder text that makes it clear
// there are no recipes available.  Also remove the unnecessary "edit" button
// to eliminate confusion.
- (void)switchToEmptyTableViewMode
{
  self.placeholderView.hidden = NO;
  self.tableView.hidden = YES;
}

- (void)switchToNonEmptyTableViewMode
{
  self.placeholderView.hidden = YES;
  self.tableView.hidden = NO;
}

- (void)recipeWasDeleted
{
  if ([self tableViewIsEmpty]) {
    [self switchToEmptyTableViewMode];
  }

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                        action:@"Delete"
                                                         label:nil
                                                         value:nil] build]];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[self.fetchedResultsController sections][section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  OBRecipeTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:@"OBRecipeCell"
                                                                    forIndexPath:indexPath];

  [self configureCell:cell atIndexPath:indexPath];

  return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    OBRecipe *recipeToRemove = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.managedObjectContext deleteObject:recipeToRemove];

    NSError *error = nil;
    [self.managedObjectContext save:&error];
    CRITTERCISM_LOG_ERROR(error);
  }
}

#pragma mark NSFetchedResultsControllerDelegate methods

// These are all boiler plate from Apple

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
  UITableView *tableView = self.tableView;

  switch(type) {

    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;

    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [self recipeWasDeleted];
      break;

    case NSFetchedResultsChangeUpdate:
      [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;

    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray
                                         arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:[NSArray
                                         arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;

    case NSFetchedResultsChangeDelete:
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    default:
      break;
  }
}

@end
