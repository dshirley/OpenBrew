//
//  OBGaugeViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBGaugeViewController.h"
#import "OBColorView.h"
#import "Crittercism+NSErrorLogging.h"
#import "OBRecipe.h"
#import "OBKvoUtils.h"

@interface OBGaugeViewController ()

@end

@implementation OBGaugeViewController

- (void)refresh
{
  NSString *value = nil;
  NSString *description = nil;
  uint32_t srm = roundf([self.recipe colorInSRM]);

  [self setColorInSrm:srm];
  if (self.metricToDisplay == OBMetricColor) {
    self.colorView.hidden = NO;
  } else {
    self.colorView.hidden = YES;
  }

  switch (self.metricToDisplay) {
    case OBMetricOriginalGravity:
      value = [NSString stringWithFormat:@"%.3f", [self.recipe originalGravity]];
      description = @"Original gravity";
      break;
    case OBMetricFinalGravity:
      value = [NSString stringWithFormat:@"%.3f", [self.recipe finalGravity]];
      description = @"Final gravity";
      break;
    case OBMetricAbv:
      value = [NSString stringWithFormat:@"%.1f%%", [self.recipe alcoholByVolume]];
      description = @"ABV";
      break;
    case OBMetricIbu:
      value = [NSString stringWithFormat:@"%d", (int) roundf([self.recipe IBUs:self.ibuFormula])];
      description = @"IBU";
      break;
    case OBMetricBuToGuRatio:
      value = [NSString stringWithFormat:@"%.2f", [self.recipe bitternessToGravityRatio:self.ibuFormula]];
      description = @"BU:GU";
      break;
    case OBMetricColor:
      value = @"";
      description = [NSString stringWithFormat:@"%ld SRM", (long)srm];
      break;
    default:
      CRITTERCISM_LOG_ERROR([NSError errorWithDomain:@"OBIngredientGauge"
                                                code:1002
                                            userInfo:@{ @"metric" : @(self.metricToDisplay) }]);
  }

  self.valueLabel.text = value;
  self.descriptionLabel.text = description;
}

- (void)setIbuFormula:(OBIbuFormula)ibuFormula
{
  _ibuFormula = ibuFormula;
  [self refresh];
}

- (void)dealloc
{
  self.recipe = nil;
}

- (void)setRecipe:(OBRecipe *)recipe
{
  [_recipe removeObserver:self forKeyPath:KVO_KEY(originalGravity)];
  [_recipe removeObserver:self forKeyPath:KVO_KEY(IBUs:)];
  [_recipe removeObserver:self forKeyPath:KVO_KEY(postBoilVolumeInGallons)];
  [_recipe removeObserver:self forKeyPath:KVO_KEY(preBoilVolumeInGallons)];

  _recipe = recipe;

  [_recipe addObserver:self forKeyPath:KVO_KEY(originalGravity) options:0 context:nil];
  [_recipe addObserver:self forKeyPath:KVO_KEY(IBUs:) options:0 context:nil];
  [_recipe addObserver:self forKeyPath:KVO_KEY(postBoilVolumeInGallons) options:0 context:nil];
  [_recipe addObserver:self forKeyPath:KVO_KEY(preBoilVolumeInGallons) options:0 context:nil];

  [self refresh];
}

- (void)setMetricToDisplay:(OBGaugeMetric)metricToDisplay
{
  _metricToDisplay = metricToDisplay;
  [self refresh];
}

- (void)setColorInSrm:(uint32_t)srm
{
  self.colorView.colorInSrm = srm;
}

- (uint32_t)colorInSrm
{
  return self.colorView.colorInSrm;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  [self refresh];
}


@end
