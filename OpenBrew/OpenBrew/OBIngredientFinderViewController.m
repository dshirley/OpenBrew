//
//  OBIngredientFinderViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientFinderViewController.h"

@interface OBIngredientFinderViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Format:  { "section =_name" : [ ingredient1, ingredient2, ... ]
@property (nonatomic, strong) NSDictionary *ingredientsIndex;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation OBIngredientFinderViewController

/**
 * Populate the ingredientsIndex dictionary which contains all of the sections
 * and the ingredients listed in each section.  Sections are alphabetical.
 */
- (void)setIngredients:(NSArray *)ingredientsSorted {
  NSMutableDictionary *newIndex = [NSMutableDictionary dictionary];
  
  for (id ingredient in ingredientsSorted) {
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

/**
 * Returns the name of a table view section for the given ingredient.  The
 * section name is based on the first letter of the ingredient.
 */
- (NSString *)sectionNameForIngredientName:(NSString *)ingredientName {
  assert([ingredientName length] > 0);
  
  return [ingredientName substringToIndex:1];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  NSString *sectionName = [_sections objectAtIndex:section];
  NSArray *ingredientsInSection = [_ingredientsIndex objectForKey:sectionName];
  return [ingredientsInSection count];
}

- (id)ingredientAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *sectionName = [_sections objectAtIndex:indexPath.section];
  NSArray *ingredientsInSection = [_ingredientsIndex objectForKey:sectionName];
  return [ingredientsInSection objectAtIndex:indexPath.row];
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

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section
{
  return nil;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"IngredientSelected"] && sender) {
    // The user chose an ingredient to add to a recipe
    // Set the selectedIngredient so that we can add it when the segue completes

    NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
    self.selectedIngredient = [self ingredientAtIndexPath:cellIndex];
  }
}

@end

