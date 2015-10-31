//
//  OBCalculationsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/17/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBTableOfContentsViewController.h"
#import "OBRecipeListViewController.h"

@interface OBTableOfContentsViewController ()
@property (nonatomic) NSArray *sections;
@property (nonatomic) NSArray *cells;
@end

@implementation OBTableOfContentsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.screenName = @"Calculations List";

  self.sections = @[ @"Recipe Design",
                     @"Mash",
                     @"Fermentation",
                     @"Carbonation"
                     ];

  self.cells = @[
                 @[ // Recipes section
                   @"recipes"],
                 @[ // Mash section
                   @"strikeWater",
                   @"mashStep",
                   @"decoction" ],
                 @[ // Fermentaiton section
                   @"abv" ],
                 @[ // Carbonation section
                   @"kegging",
                   @"bottling"
                   ]
                 ];
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  NSString *identifier = cell.reuseIdentifier;

  UIViewController *destinationViewController = nil;

  UIStoryboard *calculationsStoryboard = [UIStoryboard storyboardWithName:@"Calculations" bundle:[NSBundle mainBundle]];
  NSAssert(calculationsStoryboard, @"nil calculations storyboard");

  if ([identifier isEqualToString:@"strikeWater"]) {
    destinationViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"mash calculations"];
  } else if ([identifier isEqualToString:@"abv"]) {
    destinationViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"abv calculations"];
  } else if ([identifier isEqualToString:@"kegging"]) {
    destinationViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"carbonation calculations"];
  } else if ([identifier isEqualToString:@"bottling"]) {
    destinationViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"bottling calculations"];
  }

  if (destinationViewController) {
    [self.navigationController pushViewController:destinationViewController animated:YES];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"showRecipeList"]) {
    OBRecipeListViewController *recipeListViewController = segue.destinationViewController;
    recipeListViewController.managedObjectContext = self.managedObjectContext;
    recipeListViewController.settings = self.settings;
  } else {
    NSAssert(NO, @"Unrecognized segue: %@", segue.identifier);
  }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.sections.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView
         titleForHeaderInSection:(NSInteger)section
{
  return self.sections[section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return [self.cells[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellId = self.cells[indexPath.section][indexPath.row];
  return [tableView dequeueReusableCellWithIdentifier:cellId];
}

@end




