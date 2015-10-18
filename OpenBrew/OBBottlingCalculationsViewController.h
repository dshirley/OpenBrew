//
//  OBAbvCalculationsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface OBBottlingCalculationsViewController : GAITrackedViewController

@property (nonatomic) IBOutlet UIPickerView *beerQuantityPicker;

@property (nonatomic) IBOutlet UIPickerView *carbonationPicker;

@property (nonatomic) IBOutlet UIPickerView *temperaturePicker;

@end

