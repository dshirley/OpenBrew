//
//  OBIngredientTableViewDataSource.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientTableViewDataSource.h"
#import "Crittercism+NSErrorLogging.h"

@interface OBIngredientTableViewDataSource()

@property (nonatomic, strong) NSManagedObjectContext *ctx;
@property (nonatomic, strong) NSString *entityName;

// Read data in from CoreData and cache it in memory. If different predicates
// are applied and frequently swapped in and out, it would be a performance hit
// to keep going back to disk.
@property (nonatomic, strong) NSArray *cachedData;

// Format:  { "section =_name" : [ ingredient1, ingredient2, ... ]
@property (nonatomic, strong) NSDictionary *ingredientsIndex;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation OBIngredientTableViewDataSource

- (id)initIngredientEntityName:(NSString *)entityName
       andManagedObjectContext:(NSManagedObjectContext *)ctx
{
  self = [super init];

  if (self) {
    _ctx = ctx;
    _entityName = entityName;
    _cachedData = [self fetchIngredientData];
    [self refreshDisplayedData];
  }

  return self;
}

- (void)setPredicate:(NSPredicate *)predicate
{
  if (_predicate == predicate) {
    return;
  }

  _predicate = predicate;
  [self refreshDisplayedData];
}

#pragma mark - Data Loading Methods

// Query the CoreData store to get all of the ingredient data
- (NSArray *)fetchIngredientData
{
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:self.entityName
                                            inManagedObjectContext:self.ctx];

  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                 ascending:YES];

  [request setSortDescriptors:@[sortDescriptor]];

  NSError *error = nil;
  NSArray *array = [self.ctx executeFetchRequest:request error:&error];

  if (error) {
    CRITTERCISM_LOG_ERROR(error);
    array = [NSArray array];
  }

  return array;
}

/**
 * Requery CoreData based on current query settings.
 * Populate the ingredientsIndex dictionary which contains all of the sections
 * and the ingredients listed in each section.  Sections are alphabetical.
 */
- (void)refreshDisplayedData {
  NSMutableDictionary *newIndex = [NSMutableDictionary dictionary];
  NSArray *dataToDisplay = self.cachedData;

  if (self.predicate) {
    dataToDisplay = [self.cachedData filteredArrayUsingPredicate:self.predicate];
  }

  for (id ingredient in dataToDisplay) {
    NSString *ingredientName = [ingredient name];

    NSString *sectionName = [self sectionNameForIngredientName:ingredientName];

    NSMutableArray *ingredientsInSection = [newIndex objectForKey:sectionName];

    if (ingredientsInSection) {
      [ingredientsInSection addObject:ingredient];
    } else {
      ingredientsInSection = [NSMutableArray arrayWithObject:ingredient];
      [newIndex setObject:ingredientsInSection forKey:sectionName];
    }
  }

  _ingredientsIndex = newIndex;

  NSMutableArray *sections = [NSMutableArray array];
  for (id section in [_ingredientsIndex keyEnumerator]) {
    [sections addObject:section];
  }

  _sections = [sections sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

#pragma mark - Utility Methods

/**
 * Returns the name of a table view section for the given ingredient.  The
 * section name is based on the first letter of the ingredient.
 */
- (NSString *)sectionNameForIngredientName:(NSString *)ingredientName {
  assert([ingredientName length] > 0);

  return [ingredientName substringToIndex:1];
}

- (id)ingredientAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *sectionName = [_sections objectAtIndex:indexPath.section];
  NSArray *ingredientsInSection = [_ingredientsIndex objectForKey:sectionName];
  return [ingredientsInSection objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  NSString *sectionName = [_sections objectAtIndex:section];
  NSArray *ingredientsInSection = [_ingredientsIndex objectForKey:sectionName];
  return [ingredientsInSection count];
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
  return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
  return [self.sections objectAtIndex:section];
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
  int i;

  for (i = 0; i < [_sections count]; i++) {
    if ([title caseInsensitiveCompare:_sections[i]] <= 0) {
      return i;
    }
  }

  int sectionIndex = 0;
  if (i > 0) {
    sectionIndex = i - 1;
  }

  return sectionIndex;
}

@end
