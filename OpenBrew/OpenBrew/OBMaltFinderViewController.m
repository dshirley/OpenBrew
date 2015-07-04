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
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "OBMaltAddition.h"
#import "OBRecipe.h"
#import "Crittercism+NSErrorLogging.h"

// Google Analytics event category
static NSString* const OBGAScreenName = @"Malt Finder Screen";

// Indices of the UISegmentControl of the OBMaltFinderViewController in storyboard
#define GRAIN_SEGMENT_INDEX 0
#define EXTRACT_SEGMENT_INDEX 1
#define SUGAR_SEGMENT_INDEX 2

@interface OBMaltFinderViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;

// This allows Google Analytics to track the amount of time taken to find an ingredient
@property (nonatomic, assign) CFAbsoluteTime startTime;

@end

@implementation OBMaltFinderViewController

- (void)loadView {
  [super loadView];

  self.screenName = @"Malt Finder Screen";

  self.tableView.dataSource = self.tableViewDataSource;

  [self applyMaltTypeFilter:GRAIN_SEGMENT_INDEX];

  [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.screenName = OBGAScreenName;
  self.startTime = CFAbsoluteTimeGetCurrent();
}

// The user wants to filter by malt type (grain, extract or sugar)
// Set the data source predicate to apply a filter
- (IBAction)applyMaltTypeFilter:(UISegmentedControl *)sender {
  [self applyMaltTypeFilter:sender trackInGoogleAnalytics:YES];
}

- (void)applyMaltTypeFilter:(UISegmentedControl *)sender trackInGoogleAnalytics:(BOOL)doTracking {
  OBMaltType maltType;
  NSString *gaFilterType = @"invalid filter";

  switch (sender.selectedSegmentIndex) {
    case GRAIN_SEGMENT_INDEX:
      maltType = OBMaltTypeGrain;
      gaFilterType = @"Grain";
      break;
    case EXTRACT_SEGMENT_INDEX:
      maltType = OBMaltTypeExtract;
      gaFilterType = @"Extract";
      break;
    case SUGAR_SEGMENT_INDEX:
      maltType = OBMaltTypeSugar;
      gaFilterType = @"Sugar";
      break;
    default:
      [NSException raise:@"Segment index not defined"
                  format:@"%@", @(sender.selectedSegmentIndex)];
  }

  if (doTracking) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                          action:@"Filter"
                                                           label:gaFilterType
                                                           value:nil] build]];
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
    OBMalt *selectedMalt = [self.tableViewDataSource ingredientAtIndexPath:cellIndex];

    OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:selectedMalt
                                                              andRecipe:self.recipe];

    [self.recipe addMaltAdditionsObject:maltAddition];

    NSError *error = nil;
    [self.recipe.managedObjectContext save:&error];
    CRITTERCISM_LOG_ERROR(error);

    NSTimeInterval timeDelta = CFAbsoluteTimeGetCurrent() - self.startTime;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:OBGAScreenName
                                                         interval:@(timeDelta * 1000)
                                                             name:@"Malt selected"
                                                            label:selectedMalt.name] build]];
  }
}

@end
