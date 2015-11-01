//
//  OBMashCalculationsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/2/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "OBNumericGaugeViewController.h"

@interface OBInfusionStepViewController : GAITrackedViewController

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) OBNumericGaugeViewController *gaugeViewController;

@end
