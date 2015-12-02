//
//  OBHopAdditionSettingsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "OBSegmentedControl.h"

@class OBSettings;

@interface OBHopAdditionSettingsViewController : GAITrackedViewController

@property (nonatomic) OBSettings *settings;

@property (nonatomic) IBOutlet OBSegmentedControl *ibuFormulaSegmentedControl;

- (instancetype)initWithSettings:(OBSettings *)settings;

@end
