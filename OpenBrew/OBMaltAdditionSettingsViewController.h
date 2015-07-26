//
//  OBMaltAdditionSettingsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

// FIXME: find some other way to get the enum
#import "OBIngredientGauge.h"

// FIXME do it
#import "OBMaltAdditionTableViewDelegate.h"

@protocol OBMaltSettingsViewControllerDelegate <NSObject>

- (void)gaugeDisplaySettingChanged:(OBRecipeMetric)metric;

- (void)maltAdditionMetricSettingChanged:(OBMaltAdditionMetric)metric;

@end

@interface OBMaltAdditionSettingsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) id<OBMaltSettingsViewControllerDelegate> delegate;

+ (OBRecipeMetric)currentGaugeSetting;

+ (OBMaltAdditionMetric)currentMaltDisplaySetting;

@end
