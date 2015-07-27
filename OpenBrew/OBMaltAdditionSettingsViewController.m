//
//  OBMaltAdditionSettingsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionSettingsViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

// FIXME: importing this is weird too
#import "OBMaltAdditionTableViewDelegate.h"

// FIXME: importing the gauge to get the OBMaltGaugeMetric enum is wonky
#import "OBIngredientGauge.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Malt Addition Settings";
static NSString* const OBGASettingsAction = @"Settings change";

// FIXME: these should be in the OBSettings.m
static NSString* const OBGaugeDisplaySegmentKey = @"Malt Gauge Selected Segment";
static NSString* const OBIngredientDisplaySegmentKey = @"Malt Ingredient Selected Segment";

// What malt related metric should the gauge display.  These values should
// correspond to the indices of the MaltAdditionDisplaySettings segmentview.
typedef NS_ENUM(NSInteger, OBMaltGaugeMetric) {
  OBMaltGaugeMetricGravity,
  OBMaltGaugeMetricColor
};

OBRecipeMetric const maltSettingsToMetricMapping[] = {
  [OBMaltGaugeMetricGravity] = OBMetricOriginalGravity,
  [OBMaltGaugeMetricColor] = OBMetricColor
};


@interface OBMaltAdditionSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *gaugeDisplaySettingSegmentedControl;

@property (weak, nonatomic) IBOutlet UISegmentedControl *ingredientDisplaySettingSegmentedControl;

@end

@implementation OBMaltAdditionSettingsViewController

+ (OBRecipeMetric)currentGaugeSetting
{
  OBMaltGaugeMetric index = [[[NSUserDefaults standardUserDefaults] valueForKey:OBGaugeDisplaySegmentKey] integerValue];
  return maltSettingsToMetricMapping[index];
}

+ (OBMaltAdditionMetric)currentMaltDisplaySetting
{
  return [[[NSUserDefaults standardUserDefaults] valueForKey:OBIngredientDisplaySegmentKey] integerValue];
}

#pragma mark UIViewController overrides

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSInteger index = [[userDefaults valueForKey:OBGaugeDisplaySegmentKey] integerValue];

  self.gaugeDisplaySettingSegmentedControl.selectedSegmentIndex = index;

  index = [[userDefaults valueForKey:OBIngredientDisplaySegmentKey] integerValue];
  self.ingredientDisplaySettingSegmentedControl.selectedSegmentIndex = index;
}

#pragma mark Actions

- (IBAction)greyAreaTouchDown:(id)sender {
  [self performSegueWithIdentifier:@"dismissSettingsView" sender:self];
}

- (IBAction)gaugeDisplaySettingsChanged:(UISegmentedControl *)sender
{
  // FIXME: cleanup this method, its a bit ugly.

  OBMaltGaugeMetric metric = (OBMaltGaugeMetric) sender.selectedSegmentIndex;
  NSString *gaSettingName = @"n/a gauge action";

  switch (metric) {
    case OBMaltGaugeMetricColor:
      [self.delegate gaugeDisplaySettingChanged:OBMetricColor];
      gaSettingName = @"Show beer color";
      break;
    case OBMaltGaugeMetricGravity:
      [self.delegate gaugeDisplaySettingChanged:OBMetricOriginalGravity];
      gaSettingName = @"Show beer gravity";
      break;
    default:
      NSAssert(YES, @"Invalid gauge metric: %@", @(metric));
  }

  // Persist the selected segment so that it will appear the next time this view is loaded
  [[NSUserDefaults standardUserDefaults] setObject:@(metric) forKey:OBGaugeDisplaySegmentKey];

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                        action:OBGASettingsAction
                                                         label:gaSettingName
                                                         value:nil] build]];
}

// Linked to OBMaltAdditionDisplaySettings.xib.  This method gets called when a
// UISegment is selected that changes the information displayed for each malt
// line item.
- (IBAction)ingredientDisplaySettingsChanged:(UISegmentedControl *)sender
{
  OBMaltAdditionMetric metric = (OBMaltAdditionMetric) sender.selectedSegmentIndex;
  NSString *gaSettingName = @"n/a ingredient action";

  switch (metric) {
    case OBMaltAdditionMetricWeight:
      gaSettingName = @"Show malt weight";
      break;
    case OBMaltAdditionMetricPercentOfGravity:
      gaSettingName = @"Show % gravity";
      break;
    default:
      NSAssert(YES, @"Invalid malt addition metric: %@", @(metric));
  }

  // Persist the selected segment so that it will appear the next time this view is loaded
  [[NSUserDefaults standardUserDefaults] setObject:@(metric) forKey:OBIngredientDisplaySegmentKey];

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:OBGAScreenName
                                                        action:OBGASettingsAction
                                                         label:gaSettingName
                                                         value:nil] build]];

  // Note that the segment indices must align with the metric enum
  [self.delegate maltAdditionMetricSettingChanged:metric];
}


@end
