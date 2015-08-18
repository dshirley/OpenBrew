//
//  OBMaltAdditionSettingsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBBrewery, OBSegmentedController;

@interface OBMaltAdditionSettingsViewController : UIViewController

@property (nonatomic, strong) OBBrewery *brewery;

@property (nonatomic, readonly) OBSegmentedController *gaugeDisplaySettingController;
@property (nonatomic, readonly) OBSegmentedController *ingredientDisplaySettingController;

@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIView *greyoutView;
@property (nonatomic, weak) IBOutlet UIButton *greyoutButton;



@end
