//
//  OBCalculationsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/17/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBTableOfContentsViewController.h"
#import "OBRecipeListViewController.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface OBTableOfContentsViewController ()
@property (nonatomic) NSArray *sections;
@property (nonatomic) NSArray *cells;
@end

@implementation OBTableOfContentsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.screenName = @"Table of contents";

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
                   @"infusionStep" ],
                 @[ // Fermentaiton section
                   @"abv" ],
                 @[ // Carbonation section
                   @"kegging",
                   @"bottling"
                   ]
                 ];
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
    destinationViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"strike water calculations"];
  } else if ([identifier isEqualToString:@"infusionStep"]) {
    destinationViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"infusion step calculations"];
  } else if ([identifier isEqualToString:@"abv"]) {
    destinationViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"abv calculations"];
  } else if ([identifier isEqualToString:@"kegging"]) {
    destinationViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"carbonation calculations"];
  } else if ([identifier isEqualToString:@"bottling"]) {
    destinationViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"bottling calculations"];
  } else if ([@[ @"pitchingRate", @"colors", @"hydrometerAdjustments" ] indexOfObject:identifier] != NSNotFound) {

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:self.screenName
                                                          action:identifier
                                                           label:nil
                                                           value:nil] build]];

    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Coming Soon"
                                                       message:@"Sorry. This feature is still being built.  The Mobile Brew Lab team has been notified of your interest in this feature."
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
  }

  if (destinationViewController) {
    // Weird: http://stackoverflow.com/questions/1449339/how-do-i-change-the-title-of-the-back-button-on-a-navigation-bar
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];

    [self.navigationController pushViewController:destinationViewController animated:YES];
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




