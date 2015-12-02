//
//  OBMaltAdditionSettingsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class OBSettings, OBRecipe;

@interface OBMaltAdditionSettingsViewController : GAITrackedViewController

@property (nonatomic) OBSettings *settings;
@property (nonatomic) OBRecipe *recipe;

@property (nonatomic) IBOutlet UISlider *mashEfficiencySlider;

@property (nonatomic) IBOutlet UILabel *mashEfficiencyLabel;

- (instancetype)initWithRecipe:(OBRecipe *)recipe settings:(OBSettings *)settings;

@end
