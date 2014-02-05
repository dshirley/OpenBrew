//
//  OBIngredientFinderViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientFinderViewController.h"

@interface OBIngredientFinderViewController ()
@property (nonatomic, strong) NSDictionary *ingredientsIndex;
@property (nonatomic, strong) NSArray *sections;
@end

@implementation OBIngredientFinderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

}

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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView
                           dequeueReusableCellWithIdentifier:@"IngredientListCell"
                           forIndexPath:indexPath];

  NSString *sectionName = [_sections objectAtIndex:indexPath.section];
  NSArray *ingredientsInSection = [_ingredientsIndex objectForKey:sectionName];
  id ingredient = [ingredientsInSection objectAtIndex:indexPath.row];
  
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

@end

