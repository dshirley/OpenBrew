//
//  OBMaltAdditionSettingsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBBaseSettingsViewController.h"

@class OBSettings, OBRecipe, OBSegmentedController;

@interface OBMaltAdditionSettingsViewController : OBBaseSettingsViewController

@property (nonatomic) OBSettings *settings;
@property (nonatomic) OBRecipe *recipe;

@property (nonatomic, readonly) OBSegmentedController *gaugeDisplaySettingController;
@property (nonatomic, readonly) OBSegmentedController *ingredientDisplaySettingController;

@property (nonatomic) IBOutlet UISlider *mashEfficiencySlider;

@property (nonatomic) IBOutlet UILabel *mashEfficiencyLabel;

@end
