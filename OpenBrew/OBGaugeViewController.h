//
//  OBGaugeViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSettings.h"
#import "OBRecipe.h"
#import "OBHopAddition.h"
#import "OBGaugeView.h"

@class OBRecipe, OBColorView;

@interface OBGaugeViewController : UIViewController

// Same as self.view, but no casts are required with this one
@property (nonatomic) IBOutlet OBGaugeView *gaugeView;

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic, assign) OBGaugeMetric metricToDisplay;

- (instancetype)initWithRecipe:(OBRecipe *)recipe metricToDisplay:(OBGaugeMetric)metric;

- (void)refresh:(BOOL)animate;

@end
