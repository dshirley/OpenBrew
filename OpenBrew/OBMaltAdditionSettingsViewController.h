//
//  OBMaltAdditionSettingsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBBrewery, OBSettingsSegmentedController;

@interface OBMaltAdditionSettingsViewController : UIViewController

@property (nonatomic, strong) OBBrewery *brewery;

@property (nonatomic, readonly) OBSettingsSegmentedController *gaugeDisplaySettingController;
@property (nonatomic, readonly) OBSettingsSegmentedController *ingredientDisplaySettingController;

@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIView *settingsView;
@property (nonatomic, weak) IBOutlet UIView *greyoutView;

@end
