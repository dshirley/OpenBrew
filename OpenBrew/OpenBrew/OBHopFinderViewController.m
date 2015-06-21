//
//  OBIngredientFinderViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopFinderViewController.h"
#import "OBIngredientTableViewDataSource.h"

@interface OBHopFinderViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation OBHopFinderViewController

- (void)loadView {
  [super loadView];

  self.screenName = @"Hop Finder Screen";

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

