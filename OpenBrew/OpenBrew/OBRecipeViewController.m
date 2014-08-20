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

static NSString *const ADD_RECIPE_SEGUE = @"addRecipe";
static NSString *const SELECT_RECIPE_SEGUE = @"selectRecipe";

@interface OBRecipeViewController ()
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation OBRecipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if (!self.isMovingToParentViewController) {
    // A sub-view controller is being popped
    [self.tableView reloadData];
  }
}

- (NSArray *)recipeData
{
  OBRecipeNavigationController *nav = (OBRecipeNavigationController *) [self navigationController];
  NSManagedObjectContext *moc = [nav managedContext];
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"Recipe"
                                            inManagedObjectContext:moc];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                 ascending:YES];

  [request setSortDescriptors:@[sortDescriptor]];

  NSError *error;
  NSArray *array = [moc executeFetchRequest:request error:&error];

  assert(array);

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  OBRecipeNavigationController *nav = (OBRecipeNavigationController *) [self navigationController];
  NSManagedObjectContext *ctx = [nav managedContext];
  NSString *segueId = [segue identifier];
  OBRecipe *recipe = nil;

  if ([segueId isEqualToString:ADD_RECIPE_SEGUE]) {
    recipe = [[OBRecipe alloc] initWithContext:ctx];
    recipe.name = @"New Recipe";
    NSError *err = nil;
    [ctx save:&err];
  } else if ([segueId isEqualToString:SELECT_RECIPE_SEGUE]) {
    NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
    recipe = [self recipeData][cellIndex.row];
  }

  assert(recipe);
  id nextController = [segue destinationViewController];
  [nextController setRecipe:recipe];
}

@end
