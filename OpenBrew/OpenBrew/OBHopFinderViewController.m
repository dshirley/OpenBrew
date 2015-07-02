//
//  OBIngredientFinderViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopFinderViewController.h"
#import "OBIngredientTableViewDataSource.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "OBHops.h"

// Google Analytics event category
static NSString* const OBGAScreenName = @"Hop Finder Screen";

@interface OBHopFinderViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;

// This allows Google Analytics to track the amount of time taken to find an ingredient
@property (nonatomic, assign) CFAbsoluteTime startTime;
@end

@implementation OBHopFinderViewController

- (void)loadView {
  [super loadView];

  self.tableView.dataSource = self.tableViewDataSource;
  [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.screenName = OBGAScreenName;
  self.startTime = CFAbsoluteTimeGetCurrent();
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"IngredientSelected"] && sender) {
    // The user chose an ingredient to add to a recipe
    // Set the selectedIngredient so that we can add it when the segue completes

    NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
    self.selectedIngredient = [self.tableViewDataSource ingredientAtIndexPath:cellIndex];

    NSTimeInterval timeDelta = CFAbsoluteTimeGetCurrent() - self.startTime;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:OBGAScreenName
                                                         interval:@(timeDelta * 1000)
                                                             name:@"Hop selected"
                                                            label:self.selectedIngredient.name] build]];

  }
}

@end

