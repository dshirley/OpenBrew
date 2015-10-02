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
#import <UICountingLabel/UICountingLabel.h>

@class OBRecipe, OBColorView;

@interface OBGaugeViewController : UIViewController

@property (nonatomic) IBOutlet UICountingLabel *valueLabel;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic) IBOutlet OBColorView *colorView;

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic) OBSettings *settings;
@property (nonatomic, assign) OBGaugeMetric metricToDisplay;

- (instancetype)initWithRecipe:(OBRecipe *)recipe settings:(OBSettings *)settings metricToDisplay:(OBGaugeMetric)metric;

- (void)refresh:(BOOL)animate;

@end
