//
//  OBMaltAdditionSettingsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionSettingsViewController.h"
#import "OBSettings.h"
#import "OBSegmentedController.h"
#import "OBKvoUtils.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Malt Addition Settings";

@interface OBMaltAdditionSettingsViewController ()

@property (nonatomic) IBOutlet UISegmentedControl *gaugeDisplaySettingSegmentedControl;

@property (nonatomic) IBOutlet UISegmentedControl *ingredientDisplaySettingSegmentedControl;

@property (nonatomic) OBSegmentedController *gaugeDisplaySettingController;
@property (nonatomic) OBSegmentedController *ingredientDisplaySettingController;

@end

@implementation OBMaltAdditionSettingsViewController

#pragma mark UIViewController overrides

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.screenName = OBGAScreenName;

  OBSettings *settings = self.settings;

  self.gaugeDisplaySettingController =
    [[OBSegmentedController alloc] initWithSegmentedControl:self.gaugeDisplaySettingSegmentedControl
                                              googleAnalyticsAction:@"Malt Gauge Display"];

  [self.gaugeDisplaySettingController addSegment:@"Gravity" actionWhenSelected:^(void) {
    settings.maltGaugeDisplayMetric = @(OBMetricOriginalGravity);
  }];

  [self.gaugeDisplaySettingController addSegment:@"Color" actionWhenSelected:^(void) {
    settings.maltGaugeDisplayMetric = @(OBMetricColor);
  }];

  if (OBMetricColor == [settings.maltGaugeDisplayMetric integerValue]) {
    self.gaugeDisplaySettingSegmentedControl.selectedSegmentIndex = 1;
  } else {
    self.gaugeDisplaySettingSegmentedControl.selectedSegmentIndex = 0;
  }

  self.ingredientDisplaySettingController =
    [[OBSegmentedController alloc] initWithSegmentedControl:self.ingredientDisplaySettingSegmentedControl
                                              googleAnalyticsAction:@"Malt Primary Metric"];

  [self.ingredientDisplaySettingController addSegment:@"Weight" actionWhenSelected:^(void) {
    settings.maltAdditionDisplayMetric = @(OBMaltAdditionMetricWeight);
  }];

  [self.ingredientDisplaySettingController addSegment:@"% Gravity" actionWhenSelected:^(void) {
    settings.maltAdditionDisplayMetric = @(OBMaltAdditionMetricPercentOfGravity);
  }];

  if (OBMaltAdditionMetricPercentOfGravity == [settings.maltAdditionDisplayMetric integerValue]) {
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
