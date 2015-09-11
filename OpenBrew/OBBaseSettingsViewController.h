//
//  OBBaseSettingsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface OBBaseSettingsViewController : GAITrackedViewController

@property (nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic) IBOutlet UIView *settingsView;
@property (nonatomic) IBOutlet UIView *greyoutView;
@property (nonatomic) IBOutlet UIButton *greyoutButton;

@end
