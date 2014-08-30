//
//  OBIngredientFinderViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientFinderViewController.h"
#import "OBIngredientTableViewDataSource.h"

@interface OBIngredientFinderViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation OBIngredientFinderViewController

- (void)loadView {
  [super loadView];

  self.tableView.dataSource = self.tableViewDataSource;
  [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"IngredientSelected"] && sender) {
    // The user chose an ingredient to add to a recipe
    // Set the selectedIngredient so that we can add it when the segue completes

    NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
    self.selectedIngredient = [self.tableViewDataSource ingredientAtIndexPath:cellIndex];
  }
}

@end

