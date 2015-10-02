//
//  OBRecipeListTableViewDataSource.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBRecipeListTableViewDataSource.h"
#import "OBRecipe.h"
#import "Crittercism+NSErrorLogging.h"
#import "OBRecipeTableViewCell.h"

@interface OBRecipeListTableViewDataSource()
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) UITableView *tableView;
@end

@implementation OBRecipeListTableViewDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
             managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
{
  self = [super init];

  if (self) {
    self.tableView = tableView;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Recipe"];
    request.fetchBatchSize = 20;
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name"
                                                            ascending:YES]];

    self.managedObjectContext = managedObjectContext;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:@"recipes"];

    self.fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
      CRITTERCISM_LOG_ERROR(error);
    }
  }

  return self;
}

#pragma mark - Utility Methods

- (void)configureCell:(OBRecipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  OBRecipe *recipe = [self.fetchedResultsController objectAtIndexPath:indexPath];

  cell.recipeName.text = recipe.name;
  cell.colorView.colorInSrm = [recipe colorInSRM];
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
      self.rowDeletedCallback();
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
