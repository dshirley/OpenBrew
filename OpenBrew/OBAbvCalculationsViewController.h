//
//  OBAbvCalculationsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBAbvCalculationsViewController : UIViewController

@property (nonatomic) IBOutlet UIPickerView *startingGravityPicker;

@property (nonatomic) IBOutlet UIPickerView *finishingGravityPicker;

- (float)alcoholByVolume;

- (float)attenuation;

@end
