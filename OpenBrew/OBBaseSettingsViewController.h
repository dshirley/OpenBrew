//
//  OBBaseSettingsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface OBBaseSettingsViewController : GAITrackedViewController

@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIView *greyoutView;
@property (nonatomic, weak) IBOutlet UIButton *greyoutButton;

@end
