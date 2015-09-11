//
//  OBIngredientTableViewDataSource.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientTableViewDataSource.h"
#import "Crittercism+NSErrorLogging.h"

@implementation NSString (FetchedGroupByString)

- (NSString *)stringGroupByFirstInitial
{
  return [[self substringToIndex:1] uppercaseString];
}

@end

@interface OBIngredientTableViewDataSource()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation OBIngredientTableViewDataSource

- (id)initIngredientEntityName:(NSString *)entityName
       andManagedObjectContext:(NSManagedObjectContext *)ctx
{
  self = [super init];

  if (self) {
    self.managedObjectContext = ctx;
    self.entityName = entityName;
    [self refreshDisplayedData];
  }

  return self;
}

- (void)setPredicate:(NSPredicate *)predicate
{
  _predicate = predicate;
  [self refreshDisplayedData];
}

#pragma mark - Data Loading Methods

/**
 * Requery CoreData based on current query settings.
 * Populate the ingredientsIndex dictionary which contains all of the sections
 * and the ingredients listed in each section.  Sections are alphabetical.
 */
- (void)refreshDisplayedData
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];

  request.entity = [NSEntityDescription entityForName:self.entityName
                               inManagedObjectContext:self.managedObjectContext];

  request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"name"
                                                          ascending:YES]];
  request.predicate = self.predicate;
  request.includesSubentities = NO;

  NSError *error = nil;

  self.fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:@"name.stringGroupByFirstInitial"
                                                   cacheName:@"FIXME"];

  if (![self.fetchedResultsController performFetch:&error]) {
    CRITTERCISM_LOG_ERROR(error);
  }
}

#pragma mark - Utility Methods

- (id)ingredientAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = nil;

  cell = [tableView dequeueReusableCellWithIdentifier:@"IngredientListCell"
                                         forIndexPath:indexPath];

  id ingredient = [self ingredientAtIndexPath:indexPath];

  [[cell textLabel] setText:[ingredient name]];

  return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [self.fetchedResultsController sections].count;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
  return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  NSMutableArray *indexTitles = [NSMutableArray array];

  for (char c = 'A'; c <= 'Z'; c++) {
    NSString *title = [NSString stringWithFormat:@"%c", c];
    [indexTitles addObject:title];
  }

  return indexTitles;
}

// tell table which section corresponds to section title/index (e.g. "B",1))
- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
  NSArray *sections = self.fetchedResultsController.sections;
  NSUInteger i = 0;

  for (; i < self.fetchedResultsController.sections.count; i++) {
    id<NSFetchedResultsSectionInfo> info = sections[i];

    if ([title caseInsensitiveCompare:info.name] <= 0) {
      return i;
    }
  }

  NSUInteger sectionIndex = 0;
  if (i > 0) {
    sectionIndex = i - 1;
  }

  return sectionIndex;
}

@end
