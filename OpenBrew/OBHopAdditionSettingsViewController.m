//
//  OBHopAdditionSettingsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBHopAdditionSettingsViewController.h"
#import "OBSettings.h"
#import "OBSegmentedController.h"
#import "OBKvoUtils.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Hop Addition Settings";

@interface OBHopAdditionSettingsViewController ()

@property (nonatomic) IBOutlet UISegmentedControl *gaugeDisplaySettingSegmentedControl;

@property (nonatomic) IBOutlet UISegmentedControl *ingredientDisplaySettingSegmentedControl;

@property (nonatomic) OBSegmentedController *gaugeDisplaySettingController;
@property (nonatomic) OBSegmentedController *ingredientDisplaySettingController;

@end

@implementation OBHopAdditionSettingsViewController

#pragma mark UIViewController overrides

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.screenName = OBGAScreenName;

  OBSettings *settings = self.settings;

  self.gaugeDisplaySettingController =
    [[OBSegmentedController alloc] initWithSegmentedControl:self.gaugeDisplaySettingSegmentedControl
                                              googleAnalyticsAction:@"Hop Gauge Display"];

  [self.gaugeDisplaySettingController addSegment:@"IBU" actionWhenSelected:^(void) {
    settings.hopGaugeDisplayMetric = @(OBMetricIbu);
  }];

  [self.gaugeDisplaySettingController addSegment:@"Bitterness : Gravity" actionWhenSelected:^(void) {
    settings.hopGaugeDisplayMetric = @(OBMetricBuToGuRatio);
  }];

  if (OBMetricBuToGuRatio == [settings.hopGaugeDisplayMetric integerValue]) {
    self.gaugeDisplaySettingSegmentedControl.selectedSegmentIndex = 1;
  } else {
    self.gaugeDisplaySettingSegmentedControl.selectedSegmentIndex = 0;
  }

  self.ingredientDisplaySettingController =
    [[OBSegmentedController alloc] initWithSegmentedControl:self.ingredientDisplaySettingSegmentedControl
                                              googleAnalyticsAction:@"Hop Primary Metric"];

  [self.ingredientDisplaySettingController addSegment:@"Weight" actionWhenSelected:^(void) {
    settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricWeight);
  }];

  [self.ingredientDisplaySettingController addSegment:@"IBU" actionWhenSelected:^(void) {
    settings.hopAdditionDisplayMetric = @(OBHopAdditionMetricIbu);
  }];

  if (OBHopAdditionMetricIbu == [settings.hopAdditionDisplayMetric integerValue]) {
    self.ingredientDisplaySettingSegmentedControl.selectedSegmentIndex = 1;
  } else {
    self.ingredientDisplaySettingSegmentedControl.selectedSegmentIndex = 0;
  }
}

#pragma mark Actions

- (IBAction)greyAreaTouchDown:(id)sender {
  [self performSegueWithIdentifier:@"dismissSettingsView" sender:self];
}

@end
