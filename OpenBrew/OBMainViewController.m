//
//  OBRecipeListViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMainViewController.h"
#import "OBRecipeViewController.h"
#import "OBSettings.h"
#import "Crittercism+NSErrorLogging.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "OBRecipe.h"

// Google Analytics constants
static NSString *const OBGAScreenName = @"Main Screen";

@interface OBMainViewController ()

@property (nonatomic) OBRecipeListViewController *recipeListViewControler;
@property (nonatomic) OBCalculationsViewController *calculationsViewController;

@end

@implementation OBMainViewController

#pragma mark UIViewController Override Methods

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.screenName = OBGAScreenName;

  UIStoryboard *calculationsStoryboard = [UIStoryboard storyboardWithName:@"Calculations"
                                                                   bundle:[NSBundle mainBundle]];

  self.calculationsViewController = [calculationsStoryboard instantiateViewControllerWithIdentifier:@"calculations list"];

  self.recipeListViewControler = [self.storyboard instantiateViewControllerWithIdentifier:@"recipeList"];
  self.recipeListViewControler.managedObjectContext = self.moc;
  self.recipeListViewControler.settings = self.settings;

  NSAssert(self.childViewControllers.count == 1, @"Unexpected child view controllers: %@", self.childViewControllers);
  self.pageViewController = (id)self.childViewControllers[0];

  [self.segmentedControl addTarget:self
                            action:@selector(switchTableViewDataSource)
                  forControlEvents:UIControlEventValueChanged];

  [self.pageViewController setViewControllers:@[ self.recipeListViewControler ]
                                    direction:UIPageViewControllerNavigationDirectionForward
                                     animated:NO
                                   completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  NSString *segueId = [segue identifier];
  OBRecipe *recipe = nil;

  if ([segueId isEqualToString:@"addRecipe"]) {
    recipe = [[OBRecipe alloc] initWithContext:self.moc];

    recipe.name = @"New Recipe";
    recipe.preBoilVolumeInGallons = self.settings.defaultPreBoilSize;
    recipe.postBoilVolumeInGallons = self.settings.defaultPostBoilSize;

    NSError *err = nil;
    [self.moc save:&err];
    CRITTERCISM_LOG_ERROR(err);

    NSAssert(recipe, @"Unable to create recipe");

    id nextController = [segue destinationViewController];
    [nextController setRecipe:recipe];
    [nextController setSettings:self.settings];
  }
}

- (void)switchTableViewDataSource
{
  NSInteger index = self.segmentedControl.selectedSegmentIndex;

  switch (index) {
    case 0:
      self.navigationItem.title = @"Recipes";
      self.navigationItem.rightBarButtonItem = self.addRecipeButton;
      [self.pageViewController setViewControllers:@[ self.recipeListViewControler ]
                                        direction:UIPageViewControllerNavigationDirectionReverse
                                         animated:YES
                                       completion:nil];
      break;

    case 1:
      self.navigationItem.title = @"Calculations";
      self.navigationItem.rightBarButtonItem = nil;
      [self.pageViewController setViewControllers:@[ self.calculationsViewController ]
                                        direction:UIPageViewControllerNavigationDirectionForward
                                         animated:YES
                                       completion:nil];
      break;

    default:
      NSAssert(NO, @"Unexpected segment index: %ld", (long) index);
      break;
  }
}

@end
