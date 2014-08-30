//
//  OBMaltFinderViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltFinderViewController.h"
#import "OBIngredientTableViewDataSource.h"
#import "OBKvoUtils.h"
#import "OBMalt.h"

// Indices of the UISegmentControl of the OBMaltFinderViewController in storyboard
#define GRAIN_SEGMENT_INDEX 0
#define EXTRACT_SEGMENT_INDEX 1
#define SUGAR_SEGMENT_INDEX 2

@interface OBMaltFinderViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OBMaltFinderViewController

- (void)loadView {
  [super loadView];

  self.tableView.dataSource = self.tableViewDataSource;
  [self applyMaltTypeFilter:GRAIN_SEGMENT_INDEX];
  [self.tableView reloadData];
}

// The user wants to filter by malt type (grain, extract or sugar)
// Set the data source predicate to apply a filter
- (IBAction)applyMaltTypeFilter:(UISegmentedControl *)sender {
  OBMaltType maltType;

  switch (sender.selectedSegmentIndex) {
    case GRAIN_SEGMENT_INDEX:
      maltType = OBMaltTypeGrain;
      break;
    case EXTRACT_SEGMENT_INDEX:
      maltType = OBMaltTypeExtract;
      break;
    case SUGAR_SEGMENT_INDEX:
      maltType = OBMaltTypeSugar;
      break;
    default:
      [NSException raise:@"Segment index not defined"
                  format:@"%d", sender.selectedSegmentIndex];
  }

  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d", maltType];
  self.tableViewDataSource.predicate = predicate;
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
