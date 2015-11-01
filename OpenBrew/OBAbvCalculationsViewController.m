//
//  OBAbvCalculationsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBAbvCalculationsViewController.h"
#import "OBPickerDelegate.h"
#import "OBKvoUtils.h"
#import "OBNumericGaugeViewController.h"
#import "OBGaugePageViewControllerDataSource.h"
#import "OBRecipe.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"ABV Calculations";

@interface OBAbvCalculationsViewController ()
@property (nonatomic) OBPickerDelegate *startingGravityPickerDelegate;
@property (nonatomic) OBPickerDelegate *finishingGravityPickerDelegate;

@property (nonatomic) NSNumber *originalGravity;
@property (nonatomic) NSNumber *finalGravity;

@property (nonatomic) OBGaugePageViewControllerDataSource *pageViewControllerDataSource;
@end

@implementation OBAbvCalculationsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.screenName = OBGAScreenName;
  self.navigationItem.title = @"Alcohol Percent";
  
  [self initializeGaugePageViewController];

  self.originalGravity = @(1.050);
  self.finalGravity = @(1.010);

  self.startingGravityPickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(originalGravity)];
  self.startingGravityPickerDelegate.format = @"%.3f";
  [self.startingGravityPickerDelegate from:1.000 to:1.500 incrementBy:0.001];
  self.startingGravityPicker.delegate = self.startingGravityPickerDelegate;
  [self.startingGravityPickerDelegate updateSelectionForPicker:self.startingGravityPicker];

  self.finishingGravityPickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(finalGravity)];
  self.finishingGravityPickerDelegate.format = @"%.3f";
  [self.finishingGravityPickerDelegate from:1.000 to:1.500 incrementBy:0.001];
  self.finishingGravityPicker.delegate = self.finishingGravityPickerDelegate;
  [self.finishingGravityPickerDelegate updateSelectionForPicker:self.finishingGravityPicker];
}

- (void)initializeGaugePageViewController
{
  UIPageViewController *pageViewController = (id)self.childViewControllers[0];

  OBNumericGaugeViewController *abvGauge = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                                   keyToDisplay:KVO_KEY(alcoholByVolume)
                                                                                    valueFormat:@"%.1f%%"
                                                                                descriptionText:@"Alcohol by volume"];

  OBNumericGaugeViewController *attenuationGauge = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                                      keyToDisplay:KVO_KEY(attenuation)
                                                                                       valueFormat:@"%.0f%%"
                                                                                   descriptionText:@"Attenuation"];
  self.pageViewControllerDataSource =
    [[OBGaugePageViewControllerDataSource alloc] initWithViewControllers:@[ abvGauge, attenuationGauge ]];

  pageViewController.dataSource = self.pageViewControllerDataSource;
}

- (float)alcoholByVolume
{
  return [OBRecipe alcoholByVolumeForOriginalGravity:[self.originalGravity floatValue]
                                        finalGravity:[self.finalGravity floatValue]];
}

- (float)attenuation
{
  float sg = [self.originalGravity floatValue] - 1.0;
  float fg = [self.finalGravity floatValue] - 1.0;
  return 100 * ((sg - fg) / sg);
}

- (void)setOriginalGravity:(NSNumber *)originalGravity
{
  // The OBNumericGaugeViewController is watching these keys
  [self willChangeValueForKey:KVO_KEY(alcoholByVolume)];
  [self willChangeValueForKey:KVO_KEY(attenuation)];

  _originalGravity = originalGravity;

  [self didChangeValueForKey:KVO_KEY(alcoholByVolume)];
  [self didChangeValueForKey:KVO_KEY(attenuation)];
}

- (void)setFinalGravity:(NSNumber *)finalGravity
{
  // The OBNumericGaugeViewController is watching these keys
  [self willChangeValueForKey:KVO_KEY(alcoholByVolume)];
  [self willChangeValueForKey:KVO_KEY(attenuation)];

  _finalGravity = finalGravity;

  [self didChangeValueForKey:KVO_KEY(alcoholByVolume)];
  [self didChangeValueForKey:KVO_KEY(attenuation)];
}

@end
