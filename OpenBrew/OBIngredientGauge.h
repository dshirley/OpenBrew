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
//  approach.

#import <UIKit/UIKit.h>

@class OBRecipe;

typedef NS_ENUM(NSInteger, OBRecipeMetric) {
  OBOriginalGravity,
  OBFinalGravity,
  OBAbv,
  OBColor,
  OBIbu,
  OBBuToGuRatio
};

@interface OBIngredientGauge : UIView

@property (nonatomic, strong) OBRecipe *recipe;
@property (nonatomic, assign) OBRecipeMetric metricToDisplay;

- (id)initWithRecipe:(OBRecipe *)recipe
              metric:(OBRecipeMetric)metric
               frame:(CGRect)frame;

- (void)refresh;

@end
