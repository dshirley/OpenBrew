//
//  OBAbvCalculationsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBAbvCalculationsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIPickerView *startingGravityPicker;

@property (strong, nonatomic) IBOutlet UIPickerView *finishingGravityPicker;

@end
