//
//  OBMaltAdditionSettingsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionSettingsViewController.h"
#import "OBBrewery.h"
#import "OBSettingsSegmentedController.h"
#import "OBKvoUtils.h"

// FIXME: importing this is weird too
#import "OBMaltAdditionTableViewDelegate.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Malt Addition Settings";

@interface OBMaltAdditionSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *gaugeDisplaySettingSegmentedControl;

@property (weak, nonatomic) IBOutlet UISegmentedControl *ingredientDisplaySettingSegmentedControl;

@property (nonatomic) OBSettingsSegmentedController *gaugeDisplaySettingController;
@property (nonatomic) OBSettingsSegmentedController *ingredientDisplaySettingController;

@end

@implementation OBMaltAdditionSettingsViewController

#pragma mark UIViewController overrides

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.gaugeDisplaySettingController =
    [[OBSettingsSegmentedController alloc] initWithSegmentedControl:self.gaugeDisplaySettingSegmentedControl
                                                            brewery:self.brewery
                                                         settingKey:KVO_KEY(maltGaugeDisplayMetric)];

  [self.gaugeDisplaySettingController addSegment:@"Gravity" setsValue:@(OBMetricOriginalGravity)];
  [self.gaugeDisplaySettingController addSegment:@"Color" setsValue:@(OBMetricColor)];
  [self.gaugeDisplaySettingController updateSelectedSegment];

  self.ingredientDisplaySettingController =
    [[OBSettingsSegmentedController alloc] initWithSegmentedControl:self.ingredientDisplaySettingSegmentedControl
                                                            brewery:self.brewery
                                                         settingKey:KVO_KEY(maltAdditionDisplayMetric)];

  [self.ingredientDisplaySettingController addSegment:@"Weight" setsValue:@(OBMaltAdditionMetricWeight)];
  [self.ingredientDisplaySettingController addSegment:@"% Gravity" setsValue:@(OBMaltAdditionMetricPercentOfGravity)];
  [self.ingredientDisplaySettingController updateSelectedSegment];
}

#pragma mark Actions

- (IBAction)greyAreaTouchDown:(id)sender {
  [self performSegueWithIdentifier:@"dismissSettingsView" sender:self];
}


@end
