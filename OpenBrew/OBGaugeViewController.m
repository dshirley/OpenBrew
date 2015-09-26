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

@implementation OBGaugeViewController

- (void)refresh
{
  NSString *value = nil;
  NSString *description = nil;
  uint32_t srm = 0;

  if (self.metricToDisplay == OBMetricColor) {
    self.colorView.hidden = NO;
    self.valueLabel.hidden = YES;
    srm = roundf([self.recipe colorInSRM]);
    [self setColorInSrm:srm];
  } else {
    self.colorView.hidden = YES;
    self.valueLabel.hidden = NO;
  }

  float startValue = self.valueLabel.currentValue;
  float endValue = 0;

  switch (self.metricToDisplay) {
    case OBMetricOriginalGravity:
      endValue = [self.recipe originalGravity];
      self.valueLabel.format = @"%.3f";
      description = @"Original gravity";
      break;
    case OBMetricFinalGravity:
      endValue = [self.recipe finalGravity];
      self.valueLabel.format = @"%.3f";
      description = @"Final gravity";
      break;
    case OBMetricAbv:
      endValue = [self.recipe alcoholByVolume];
      self.valueLabel.format = @"%.1f";
      description = @"ABV";
      break;
    case OBMetricIbu:
      endValue = roundf([self.recipe IBUs:self.ibuFormula]);
      self.valueLabel.format = @"%d";
      description = @"IBU";
      break;
    case OBMetricBuToGuRatio:
      endValue = [self.recipe bitternessToGravityRatio:self.ibuFormula];
      self.valueLabel.format = @"%.2f";
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

  self.descriptionLabel.text = description;

  if (OBMetricColor != self.metricToDisplay) {
    NSTimeInterval duration = self.willAnimateNextRefresh ? 0.25 : 0;

    self.valueLabel.method = UILabelCountingMethodEaseOut;
    [self.valueLabel countFrom:startValue to:endValue withDuration:duration];
  }

  self.willAnimateNextRefresh = YES;
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
