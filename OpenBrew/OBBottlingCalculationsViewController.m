//
//  OBCarbonationCalculationsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBBottlingCalculationsViewController.h"
#import "OBPickerDelegate.h"
#import "OBKvoUtils.h"
#import "OBNumericGaugeViewController.h"
#import "OBGaugePageViewControllerDataSource.h"
#import "OBRecipe.h"
#import "OBUnitConversion.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Bottling Calculations";

@interface OBBottlingCalculationsViewController ()
@property (nonatomic) OBPickerDelegate *beerQuantityPickerDelegate;
@property (nonatomic) OBPickerDelegate *carbonationPickerDelegate;
@property (nonatomic) OBPickerDelegate *temperaturePickerDelegate;

@property (nonatomic) NSNumber *beerQuantityInGallons;
@property (nonatomic) NSNumber *carbonationInVolumes;
@property (nonatomic) NSNumber *temperatureInFahrenheit;

@property (nonatomic) OBGaugePageViewControllerDataSource *pageViewControllerDataSource;
@end

@implementation OBBottlingCalculationsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.screenName = OBGAScreenName;

  [self initializeGaugePageViewController];

  self.carbonationInVolumes = @(2.5);
  self.temperatureInFahrenheit = @(70);
  self.beerQuantityInGallons = @(5.0);

  self.carbonationPickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(carbonationInVolumes)];
  self.carbonationPickerDelegate.format = @"%.1f";
  [self.carbonationPickerDelegate from:1.0 to:4.5 incrementBy:0.1];
  self.carbonationPicker.delegate = self.carbonationPickerDelegate;
  [self.carbonationPickerDelegate updateSelectionForPicker:self.carbonationPicker];

  self.temperaturePickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(temperatureInFahrenheit)];
  self.temperaturePickerDelegate.format = @"%.0f°";
  [self.temperaturePickerDelegate from:32 to:85 incrementBy:1];
  self.temperaturePicker.delegate = self.temperaturePickerDelegate;
  [self.temperaturePickerDelegate updateSelectionForPicker:self.temperaturePicker];

  self.beerQuantityPickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(beerQuantityInGallons)];
  self.beerQuantityPickerDelegate.format = @"%.2f";
  [self.beerQuantityPickerDelegate from:0 to:10 incrementBy:0.25];
  self.beerQuantityPicker.delegate = self.beerQuantityPickerDelegate;
  [self.beerQuantityPickerDelegate updateSelectionForPicker:self.beerQuantityPicker];
}

- (void)initializeGaugePageViewController
{
  UIPageViewController *pageViewController = (id)self.childViewControllers[0];

  OBNumericGaugeViewController *cornSugarGauge = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                                   keyToDisplay:KVO_KEY(cornSugarInOunces)
                                                                                    valueFormat:@"%.1f"
                                                                                descriptionText:@"Corn sugar (oz)"];

  OBNumericGaugeViewController *caneSugarGauge = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                                        keyToDisplay:KVO_KEY(caneSugarInOunces)
                                                                                         valueFormat:@"%.1f"
                                                                                     descriptionText:@"Cane sugar (oz)"];

  self.pageViewControllerDataSource =
    [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:@[ cornSugarGauge, caneSugarGauge ]];

  pageViewController.dataSource = self.pageViewControllerDataSource;
}

// TODO: fix these
- (float)caneSugarInOunces
{
  return [self cornSugarInOunces] * .913;
}

// Citation:
// https://www.homebrewersassociation.org/attachments/0000/2497/Math_in_Mash_SummerZym95.pdf
- (float)cornSugarInOunces
{
  float beerGallons = [self.beerQuantityInGallons floatValue];
  float co2Volumes = [self.carbonationInVolumes floatValue];
  float T = [self.temperatureInFahrenheit floatValue];

  float initialCO2Volumes = 3.0378 - (.050062 * T) + (.00026555 * T * T);

  float cornSugarInGrams = 15.195 * beerGallons * (co2Volumes - initialCO2Volumes);
  return gramsToOunces(cornSugarInGrams);
}

- (void)setTemperatureInFahrenheit:(NSNumber *)temperatureInFahrenheit
{
  // The OBNumericGaugeViewController is watching these keys
  [self willChangeValueForKey:KVO_KEY(caneSugarInOunces)];
  [self willChangeValueForKey:KVO_KEY(cornSugarInOunces)];

  _temperatureInFahrenheit = temperatureInFahrenheit;

  [self didChangeValueForKey:KVO_KEY(caneSugarInOunces)];
  [self didChangeValueForKey:KVO_KEY(cornSugarInOunces)];
}

- (void)setBeerQuantityInGallons:(NSNumber *)beerQuantityInGallons
{
  // The OBNumericGaugeViewController is watching these keys
  [self willChangeValueForKey:KVO_KEY(caneSugarInOunces)];
  [self willChangeValueForKey:KVO_KEY(cornSugarInOunces)];

  _beerQuantityInGallons = beerQuantityInGallons;

  [self didChangeValueForKey:KVO_KEY(caneSugarInOunces)];
  [self didChangeValueForKey:KVO_KEY(cornSugarInOunces)];
}

- (void)setCarbonationInVolumes:(NSNumber *)carbonationInPsi
{
  // The OBNumericGaugeViewController is watching these keys
  [self willChangeValueForKey:KVO_KEY(caneSugarInOunces)];
  [self willChangeValueForKey:KVO_KEY(cornSugarInOunces)];

  _carbonationInVolumes = carbonationInPsi;

  [self didChangeValueForKey:KVO_KEY(caneSugarInOunces)];
  [self didChangeValueForKey:KVO_KEY(cornSugarInOunces)];
}

@end
