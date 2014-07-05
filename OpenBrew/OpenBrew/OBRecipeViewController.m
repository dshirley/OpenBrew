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

@interface OBRecipeViewController ()

@end

@implementation OBRecipeViewController
@synthesize recipesTableView;

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
  
  UITableView *view = [self recipesTableView];
  [view reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OBRecipeCell"
                                                          forIndexPath:indexPath];
  
  [[cell textLabel] setText:[NSString stringWithFormat:@"test%d", [indexPath row]]];
  
  return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  OBRecipeNavigationController *nav = (OBRecipeNavigationController *) [self navigationController];
  NSManagedObjectContext *ctx = [nav managedContext];
  
  if ([[segue identifier] isEqualToString:@"addRecipe"]) {
    OBRecipe *recipe = [[OBRecipe alloc] initWithContext:ctx];
    
    id nextController = [segue destinationViewController];
    [nextController setRecipe:recipe];
  }
}

@end
