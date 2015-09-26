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
#import <UICountingLabel/UICountingLabel.h>

@class OBRecipe, OBColorView;

@interface OBGaugeViewController : UIViewController

@property (nonatomic) IBOutlet UICountingLabel *valueLabel;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic) IBOutlet OBColorView *colorView;

@property (nonatomic) OBRecipe *recipe;
@property (nonatomic, assign) OBGaugeMetric metricToDisplay;
@property (nonatomic, assign) OBIbuFormula ibuFormula;

// Determines if a refresh will animate changing valueLabel by counting from
// the current value to the next value. This field starts off as false and
// becomes true after the first refresh. It can be manually set to false
// (which could be desirable for testing).
@property (nonatomic, assign) BOOL willAnimateNextRefresh;

- (void)refresh;

@end
