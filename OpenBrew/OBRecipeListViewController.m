//
//  OBRecipeListViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipeListViewController.h"
#import "OBRecipeViewController.h"
#import "OBSettings.h"
#import "Crittercism+NSErrorLogging.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "OBRecipeListTableViewDataSource.h"
#import "OBCalculationsTableViewDataSource.h"

// Google Analytics constants
static NSString *const OBGAScreenName = @"Recipe List Screen";

static NSString *const ADD_RECIPE_SEGUE = @"addRecipe";
static NSString *const SELECT_RECIPE_SEGUE = @"selectRecipe";

@interface OBRecipeListViewController ()

@property (nonatomic) OBRecipeListTableViewDataSource *recipeListDataSource;
@property (nonatomic) OBCalculationsTableViewDataSource *calculationsDataSource;

// Variables for tracking first interaction time with Google Analytics
@property (nonatomic, assign) CFAbsoluteTime loadTime;

@property (nonatomic, assign) BOOL firstInteractionComplete;

@property (nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation OBRecipeListViewController

#pragma mark UIViewController Override Methods

- (void)viewDidLoad
{
  [super viewDidLoad];

  id weakself = self;

  self.calculationsDataSource = [[OBCalculationsTableViewDataSource alloc] init];
  self.recipeListDataSource = [[OBRecipeListTableViewDataSource alloc] initWithTableView:self.tableView
                                                                    managedObjectContext:self.moc];
  self.recipeListDataSource.rowDeletedCallback = ^() {
    [weakself recipeWasDeleted];
  };

  self.tableView.dataSource = self.recipeListDataSource;

  self.placeholderView.messageLabel.text = @"No Recipes";
  self.placeholderView.instructionsLabel.text = @"Tap the '+' button to create a recipe.";

  self.firstInteractionComplete = NO;
  self.loadTime = CFAbsoluteTimeGetCurrent();

  [self.segmentedControl addTarget:self
                            action:@selector(switchTableViewDataSource)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.screenName = OBGAScreenName;

  if ([self tableViewIsEmpty]) {
    [self switchToEmptyTableViewMode];
  } else {
    [self switchToNonEmptyTableViewMode];
  }

  [self.tableView reloadData];
}

- (void)switchTableViewDataSource
{
  NSInteger index = self.segmentedControl.selectedSegmentIndex;

  switch (index) {
    case 0:
      self.tableView.dataSource = self.recipeListDataSource;
      break;

    case 1:
      self.tableView.dataSource = self.calculationsDataSource;
      break;

    default:
      NSAssert(NO, @"Unexpected segment index: %d", index);
      break;
  }

  [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSString *segueId = [segue identifier];
  OBRecipe *recipe = nil;

  if (!self.firstInteractionComplete) {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    CFTimeInterval timeDelta = CFAbsoluteTimeGetCurrent() - self.loadTime;

    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:OBGAScreenName
                                                         interval:@((NSUInteger)(timeDelta * 1000))
                                                             name:@"First Interaction"
                                                            label:segueId] build]];

    self.firstInteractionComplete = YES;
  }

  if ([segueId isEqualToString:ADD_RECIPE_SEGUE]) {
    recipe = [[OBRecipe alloc] initWithContext:self.moc];

    recipe.name = @"New Recipe";
    recipe.preBoilVolumeInGallons = self.settings.defaultPreBoilSize;
    recipe.postBoilVolumeInGallons = self.settings.defaultPostBoilSize;

    NSError *err = nil;
    [self.moc save:&err];
    CRITTERCISM_LOG_ERROR(err);

    NSAssert(recipe, @"Unable to create recipe");

  } else if ([segueId isEqualToString:SELECT_RECIPE_SEGUE]) {
    NSIndexPath *cellIndex = [self.tableView indexPathForCell:sender];
    recipe = [self.recipeListDataSource.fetchedResultsController objectAtIndexPath:cellIndex];
    NSAssert(recipe, @"Recipe was nil for cell %@", cellIndex);
  }

  id nextController = [segue destinationViewController];
  [nextController setRecipe:recipe];
  [nextController setSettings:self.settings];
}


#pragma mark UITableView Utility Methods

- (BOOL)tableViewIsEmpty
{
  return 0 == [self.recipeListDataSource.fetchedResultsController.sections[0] numberOfObjects];
}

// Changes the look and feel to have placeholder text that makes it clear
// there are no recipes available.  Also remove the unnecessary "edit" button
// to eliminate confusion.
- (void)switchToEmptyTableViewMode
{
  self.placeholderView.hidden = NO;
  self.tableView.hidden = YES;
}

- (void)switchToNonEmptyTableViewMode
{
  self.placeholderView.hidden = YES;
  self.tableView.hidden = NO;
}

- (void)recipeWasDeleted
{
  if ([self tableViewIsEmpty]) {
    [self switchToEmptyTableViewMode];
  }

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                        action:@"Delete"
                                                         label:nil
                                                         value:nil] build]];
}

@end
