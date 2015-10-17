//
//  OBAbvCalculationsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBBottlingCalculationsViewController : UIViewController

@property (nonatomic) IBOutlet UIPickerView *beerQuantityPicker;

@property (nonatomic) IBOutlet UIPickerView *carbonationPicker;

@property (strong, nonatomic) IBOutlet UIPickerView *temperaturePicker;

@end

