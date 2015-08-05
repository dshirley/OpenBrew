//
//  OBInstrumentGauge.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/7/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//
//  This class is responsible for displaying a single recipe metric.
//  The design diverges from the MVC model as this is a view class and it
//  talks directly to the model.  It seemed far and away the most efficient
//  approach. FIXME ^^^^

#import <UIKit/UIKit.h>

// FIXME: the view shouldn't be importing part of the model
#import "OBBrewery.h"

@class OBRecipe;

@interface OBIngredientGauge : UIView

@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, assign) OBGaugeMetric metricToDisplay;

- (id)initWithFrame:(CGRect)frame;

- (void)refresh;

@end
