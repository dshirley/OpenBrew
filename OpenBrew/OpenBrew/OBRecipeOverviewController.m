//
//  OBRecipeOverviewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/26/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipeOverviewController.h"
#import "OBMaltAdditionViewController.h"
#import "OBYeastAddition.h"
#import "OBYeast.h"
#import "OBBatchSizeViewController.h"
#import "OBHopAdditionViewController.h"

@interface OBRecipeOverviewController ()
@property (nonatomic, weak) IBOutlet UITextField *recipeNameTextField;
@property (nonatomic, weak) IBOutlet UILabel *batchSizeLabel;
@property (nonatomic, weak) IBOutlet UILabel *styleLabel;
@property (nonatomic, weak) IBOutlet UILabel *yeastLabel;
@property (nonatomic, weak) IBOutlet UILabel *originalGravityLabel;
@property (nonatomic, weak) IBOutlet UILabel *finalGravityLabel;
@property (nonatomic, weak) IBOutlet UILabel *abvLabel;
@property (nonatomic, weak) IBOutlet UILabel *colorLabel;
@property (nonatomic, weak) IBOutlet UILabel *ibuLabel;
@end

@implementation OBRecipeOverviewController
@synthesize abvLabel;
@synthesize batchSizeLabel;
@synthesize colorLabel;
@synthesize finalGravityLabel;
@synthesize ibuLabel;
@synthesize originalGravityLabel;
@synthesize yeastLabel;

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
  [self reloadData];
  self.recipeNameTextField.text = self.recipe.name;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if (!self.isMovingToParentViewController) {
    // A sub-view controller is being popped
    [self reloadData];
    [self.recipe.managedObjectContext save:nil];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSString *identifier = [segue identifier];

  if ([identifier isEqualToString:@"maltSegue"]) {

    OBMaltAdditionViewController *maltAdditionViewController = [segue destinationViewController];
    maltAdditionViewController.recipe = self.recipe;
    
  } else if ([identifier isEqualToString:@"hopsSegue"]) {

    OBHopAdditionViewController *hopsViewController = [segue destinationViewController];
    hopsViewController.recipe = self.recipe;

  } else if ([identifier isEqualToString:@"selectBatchSize"]) {

    OBBatchSizeViewController *batchSizeViewController = segue.destinationViewController;
    batchSizeViewController.recipe = self.recipe;

  }
}

- (void)reloadData {

  NSString *abv = [NSString stringWithFormat:@"%.1f%%", [[self recipe] alcoholByVolume]];
  [[self abvLabel] setText:abv];

  NSString *batchSize = [NSString stringWithFormat:@"%.1f gallons",
                         [[[self recipe] desiredBeerVolumeInGallons] floatValue]];
  
  [[self batchSizeLabel] setText:batchSize];
  
  // FIXME: need to have a color method in recipe
  [colorLabel setText:@"FIXME SRM"];
  
  NSString *fg = [NSString stringWithFormat:@"%.3f", [[self recipe] finalGravity]];
  [[self finalGravityLabel] setText:fg];

  // FIXME: Round instead of int()
  NSString *ibu = [NSString stringWithFormat:@"%d IBU", (int) [[self recipe] IBUs]];
  [[self ibuLabel] setText:ibu];

  NSString *og = [NSString stringWithFormat:@"%.3f", [[self recipe] originalGravity]];
  [[self originalGravityLabel] setText:og];

  NSString *yeast = [[[[self recipe] yeast] yeast] name];
  [[self yeastLabel] setText:yeast];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  assert(textField == self.recipeNameTextField);

  self.recipe.name = self.recipeNameTextField.text;

  NSError *error = nil;
  [self.recipe.managedObjectContext save:&error];
}

@end
