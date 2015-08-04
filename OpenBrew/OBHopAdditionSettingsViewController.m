//
//  OBHopAdditionSettingsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBHopAdditionSettingsViewController.h"
#import "OBBrewery.h"
#import "OBSettingsSegmentedController.h"
#import "OBKvoUtils.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Hop Addition Settings";

@interface OBHopAdditionSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *gaugeDisplaySettingSegmentedControl;

@property (weak, nonatomic) IBOutlet UISegmentedControl *ingredientDisplaySettingSegmentedControl;

@property (nonatomic) OBSettingsSegmentedController *gaugeDisplaySettingController;
@property (nonatomic) OBSettingsSegmentedController *ingredientDisplaySettingController;

@end

@implementation OBHopAdditionSettingsViewController

#pragma mark UIViewController overrides

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.gaugeDisplaySettingController =
  [[OBSettingsSegmentedController alloc] initWithSegmentedControl:self.gaugeDisplaySettingSegmentedControl
                                                          brewery:self.brewery
                                                       settingKey:KVO_KEY(hopGaugeDisplayMetric)];

  [self.gaugeDisplaySettingController addSegment:@"IBU" setsValue:@(OBMetricIbu)];
  [self.gaugeDisplaySettingController addSegment:@"Bittering : Gravity" setsValue:@(OBMetricBuToGuRatio)];
  [self.gaugeDisplaySettingController updateSelectedSegment];

  self.ingredientDisplaySettingController =
  [[OBSettingsSegmentedController alloc] initWithSegmentedControl:self.ingredientDisplaySettingSegmentedControl
                                                          brewery:self.brewery
                                                       settingKey:KVO_KEY(hopAdditionDisplayMetric)];

  [self.ingredientDisplaySettingController addSegment:@"Weight" setsValue:@(OBMaltAdditionMetricWeight)];
  [self.ingredientDisplaySettingController addSegment:@"IBU" setsValue:@(OBMaltAdditionMetricPercentOfGravity)];
  [self.ingredientDisplaySettingController updateSelectedSegment];
}

#pragma mark Actions

- (IBAction)greyAreaTouchDown:(id)sender {
  [self performSegueWithIdentifier:@"dismissSettingsView" sender:self];
}

@end
