//
//  OBInstrumentGauge.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/7/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientGauge.h"
#import "OBColorView.h"
#import "Crittercism+NSErrorLogging.h"

// FIXME: decide if the view should be importing recipe
#import "OBRecipe.h"

#define VALUE_HEIGHT 90
#define VALUE_FONT_SIZE 64

#define DESCRIPTION_Y (VALUE_HEIGHT - 10)
#define DESCRIPTION_HEIGHT 20

@interface OBIngredientGauge()
@property (nonatomic) IBOutlet UILabel *valueLabel;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic) IBOutlet OBColorView *colorView;
@end


@implementation OBIngredientGauge

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];

  if (self) {
    [self doInit];
  }

  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  
  if (self) {
    [self doInit];
  }
  
  return self;
}

- (void)doInit
{
  UIView *view = [[NSBundle mainBundle] loadNibNamed:@"OBIngredientGauge" owner:self options:nil][0];
  view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
  [self addSubview:view];
}

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
      value = [NSString stringWithFormat:@"%d", (int) roundf([self.recipe IBUs])];
      description = @"IBU";
      break;
    case OBMetricBuToGuRatio:
      value = [NSString stringWithFormat:@"%.2f", [self.recipe bitternessToGravityRatio]];
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

- (void)setRecipe:(OBRecipe *)recipe
{
  _recipe = recipe;
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

@end
