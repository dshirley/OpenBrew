//
//  OBGaugeViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSettings.h"
#import "OBHopAddition.h"

@class OBRecipe, OBColorView;

@interface OBGaugeViewController : UIViewController

@property (nonatomic) IBOutlet UILabel *valueLabel;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic) IBOutlet OBColorView *colorView;

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic, assign) OBGaugeMetric metricToDisplay;
@property (nonatomic, assign) OBIbuFormula ibuFormula;

- (void)refresh;

@end
