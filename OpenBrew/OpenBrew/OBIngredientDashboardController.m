//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientDashboardController.h"
#import "OBIngredientFinderViewController.h"

#import "OBMaltAddition.h"

@interface OBIngredientDashboardController ()
- (void)reload;
@end

@implementation OBIngredientDashboardController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
      
        // Custom initialization
    }
    return self;
}

- (void)loadView {
  [super loadView];
  [self reload];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self reload];
}

- (void)reload {
  _gauge.value.text = [_delegate gaugeValueForRecipe:_recipe];
  _gauge.description.text = [_delegate gaugeDescriptionText];

  [_addButton setTitle:[_delegate addButtonText] forState:UIControlStateNormal];
  [_ingredientTable reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"addIngredient"]) {

    OBIngredientFinderViewController *next = [segue destinationViewController];
    
    NSManagedObjectContext *moc = self.recipe.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Malt"
                                              inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];\
    
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    
    assert(array);
    
    [next setIngredients:array];
  }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[self delegate] tableView:tableView
                        numberOfRowsInSection:section
                          forRecipe:self.recipe];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView
                           dequeueReusableCellWithIdentifier:@"OBIngredientAddition"
                           forIndexPath:indexPath];
  
  [[self delegate] populateCell:cell
                       forIndex:indexPath
                      andRecipe:self.recipe];
  
  return cell;
}

- (void)ingredientSelected:(UIStoryboardSegue *)unwindSegue
{
  if ([[unwindSegue identifier] isEqualToString:@"IngredientSelected"]) {
    OBIngredientFinderViewController *finderView = [unwindSegue sourceViewController];
    id ingredient = [finderView selectedIngredient];
    [self.delegate addIngredient:ingredient toRecipe:self.recipe];
    [self reload];
  }
}

@end

@implementation OBMaltDashboardDelegate

- (NSString *)addButtonText {
  return @"Add Malt";
}

- (NSString *)gaugeValueForRecipe:(OBRecipe *)recipe {
  float gravity = [recipe originalGravity];
  return [NSString stringWithFormat:@"%.3f", gravity];
}

- (NSString *)gaugeDescriptionText {
  return @"Estimated Starting Gravity";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
             forRecipe:(OBRecipe *)recipe
{
  return [[recipe maltAdditions] count];
}

- (void)populateCell:(UITableViewCell *)cell
            forIndex:(NSIndexPath *)index
           andRecipe:(OBRecipe *) recipe
{
  NSSortDescriptor *sortBySize = [[NSSortDescriptor alloc] initWithKey:@"quantityInPounds"
                                                             ascending:NO];

  NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];

  NSArray *sortSpecification = @[ sortBySize, sortByName ];

  NSArray *malts = [[recipe maltAdditions] sortedArrayUsingDescriptors:sortSpecification];

  OBMaltAddition *maltAddition = malts[index.row];
  
  [[cell textLabel] setText:[maltAddition name]];
  [[cell detailTextLabel] setText:[maltAddition quantityText]];
}

- (void)addIngredient:(id)ingredient toRecipe:(OBRecipe *)recipe {
  OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:ingredient];
  [recipe addMaltAdditionsObject:maltAddition];

}

@end


@implementation OBHopsDashboardDelegate

- (NSString *)addButtonText {
  return @"Add Hops";
}

- (NSString *)gaugeValueForRecipe:(OBRecipe *)recipe {
  float ibus = [recipe IBUs];
  return [NSString stringWithFormat:@"%.0f", ibus];
}

- (NSString *)gaugeDescriptionText {
  return @"Estimated IBUs";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
             forRecipe:(OBRecipe *)recipe
{
  return 3;
}

- (void)populateCell:(UITableViewCell *)cell
            forIndex:(NSIndexPath *)index
           andRecipe:(OBRecipe *) recipe
{
  [[cell textLabel] setText:@"Hops"];
  [[cell detailTextLabel] setText:@"12"];
}

- (void)addIngredient:(id)ingredient toRecipe:(OBRecipe *)recipe {
  [recipe addHopAdditionsObject:ingredient];
}

@end
