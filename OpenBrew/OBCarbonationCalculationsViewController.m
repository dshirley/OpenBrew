//
//  OBCarbonationCalculationsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBCarbonationCalculationsViewController.h"
#import "OBPickerDelegate.h"
#import "OBKvoUtils.h"
#import "OBNumericGaugeViewController.h"
#import "OBGaugePageViewControllerDataSource.h"
#import "OBRecipe.h"

@interface OBCarbonationCalculationsViewController ()
@property (nonatomic) OBPickerDelegate *temperaturePickerDelegate;
@property (nonatomic) OBPickerDelegate *carbonationPickerDelegate;

@property (nonatomic) NSNumber *temperatureInFahrenheit;
@property (nonatomic) NSNumber *carbonationInVolumes;

@property (nonatomic) OBGaugePageViewControllerDataSource *pageViewControllerDataSource;
@end

@implementation OBCarbonationCalculationsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  [self initializeGaugePageViewController];

  self.temperatureInFahrenheit = @(35);
  self.carbonationInVolumes = @(2.5);

  self.temperaturePickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(temperatureInFahrenheit)];
  self.temperaturePickerDelegate.format = @"%.0f°";
  [self.temperaturePickerDelegate from:32 to:80 incrementBy:1];
  self.temperaturePicker.delegate = self.temperaturePickerDelegate;
  [self.temperaturePickerDelegate updateSelectionForPicker:self.temperaturePicker];

  self.carbonationPickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(carbonationInVolumes)];
  self.carbonationPickerDelegate.format = @"%.1f";
  [self.carbonationPickerDelegate from:1.0 to:4.0 incrementBy:0.1];
  self.carbonationPicker.delegate = self.carbonationPickerDelegate;
  [self.carbonationPickerDelegate updateSelectionForPicker:self.carbonationPicker];
}

- (void)initializeGaugePageViewController
{
  UIPageViewController *pageViewController = (id)self.childViewControllers[0];

  OBNumericGaugeViewController *psiGauge = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                                   keyToDisplay:KVO_KEY(pressureInPsi)
                                                                                    valueFormat:@"%.0f"
                                                                                descriptionText:@"Required Pressure (psi)"];

  OBNumericGaugeViewController *kpiGauge = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                                        keyToDisplay:KVO_KEY(pressureInKiloPascals)
                                                                                         valueFormat:@"%.0f"
                                                                                     descriptionText:@"Required Pressure (kPa)"];

  self.pageViewControllerDataSource =
    [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:@[ psiGauge, kpiGauge ]];

  pageViewController.dataSource = self.pageViewControllerDataSource;
}

// Citation: http://hbd.org/hbd/archive/2788.html#2788-8
- (float)pressureInPsi
{
  float T = [self.temperatureInFahrenheit floatValue];
  float V = [self.carbonationInVolumes floatValue];
  return -16.6999 - (0.0101059 * T) + (0.00116512 * T * T) + (0.173354 * T * V) + (4.24267 * V) - (0.0684226 * V * V);
}

- (float)pressureInKiloPascals
{
  return [self pressureInPsi] * 6.89476;
}

- (void)setTemperatureInFahrenheit:(NSNumber *)temperatureInFahrenheit
{
  // The OBNumericGaugeViewController is watching these keys
  [self willChangeValueForKey:KVO_KEY(pressureInPsi)];
  [self willChangeValueForKey:KVO_KEY(pressureInKiloPascals)];

  _temperatureInFahrenheit = temperatureInFahrenheit;

  [self didChangeValueForKey:KVO_KEY(pressureInPsi)];
  [self didChangeValueForKey:KVO_KEY(pressureInKiloPascals)];
}

- (void)setCarbonationInVolumes:(NSNumber *)carbonationInPsi
{
  // The OBNumericGaugeViewController is watching these keys
  [self willChangeValueForKey:KVO_KEY(pressureInPsi)];
  [self willChangeValueForKey:KVO_KEY(pressureInKiloPascals)];

  _carbonationInVolumes = carbonationInPsi;

  [self didChangeValueForKey:KVO_KEY(pressureInPsi)];
  [self didChangeValueForKey:KVO_KEY(pressureInKiloPascals)];
}

@end
