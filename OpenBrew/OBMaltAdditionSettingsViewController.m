//
//  OBMaltAdditionSettingsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionSettingsViewController.h"
#import "OBSettings.h"
#import "OBRecipe.h"
#import "OBKvoUtils.h"
#import <math.h>

// Google Analytics constants
static NSString* const OBGAScreenName = @"Malt Addition Settings";

@implementation OBMaltAdditionSettingsViewController

- (instancetype)initWithRecipe:(OBRecipe *)recipe settings:(OBSettings *)settings
{
  self = [super initWithNibName:@"OBMaltAdditionSettingsViewController"
                         bundle:[NSBundle mainBundle]];

  if (self) {
    self.recipe = recipe;
    self.settings = settings;
  }

  return self;
}

#pragma mark UIViewController overrides

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  NSAssert(self.settings, @"Settings are nil");
  NSAssert(self.recipe, @"Recipe is nil");

  self.screenName = OBGAScreenName;

  self.mashEfficiencySlider.minimumValue = 0.0;
  self.mashEfficiencySlider.maximumValue = 1.0;
  self.mashEfficiencySlider.value = [self.recipe.mashEfficiency floatValue];

  [self.mashEfficiencySlider addTarget:self
                                action:@selector(sliderValueChanged:)
                      forControlEvents:UIControlEventValueChanged];

  [self updateMashEfficiencyLabel];
}

- (void)updateMashEfficiencyLabel
{
  int mashEfficiency = roundf(100.0 * [self.recipe.mashEfficiency floatValue]);
  self.mashEfficiencyLabel.text = [NSString stringWithFormat:@"Efficiency: %d%%", mashEfficiency];
}

#pragma mark Actions

- (IBAction)greyAreaTouchDown:(id)sender {
  [self performSegueWithIdentifier:@"dismissSettingsView" sender:self];
}

- (void)sliderValueChanged:(id)sender {
  self.recipe.mashEfficiency = @(self.mashEfficiencySlider.value);
  [self updateMashEfficiencyLabel];
}


@end
