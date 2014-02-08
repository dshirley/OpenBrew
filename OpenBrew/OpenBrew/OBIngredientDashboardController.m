//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientDashboardController.h"
#import "OBIngredientFinderViewController.h"

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
                        numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView
                           dequeueReusableCellWithIdentifier:@"OBIngredientAddition"
                           forIndexPath:indexPath];
  
  [[self delegate] populateCell:cell forIndex:indexPath];
  
  return cell;
}

- (void)unwindToIngredientList:(UIStoryboardSegue *)unwindSegue
{
  // TODO: implement me
}

@end

@implementation OBMaltDashboardDelegate

- (NSString *)addButtonText {
  return @"Add Malt";
}

- (NSString *)gaugeValueForRecipe:(OBRecipe *)recipe {
  float gravity = [recipe originalGravity];
  return [NSString stringWithFormat:@"%.2f", gravity];
}

- (NSString *)gaugeDescriptionText {
  return @"Estimated Starting Gravity";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}

- (void)populateCell:(UITableViewCell *)cell forIndex:(NSIndexPath *)index {
  [[cell textLabel] setText:@"Malt"];
  [[cell detailTextLabel] setText:@"1.053"];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}

- (void)populateCell:(UITableViewCell *)cell forIndex:(NSIndexPath *)index {
  [[cell textLabel] setText:@"Hops"];
  [[cell detailTextLabel] setText:@"12"];
}

@end
