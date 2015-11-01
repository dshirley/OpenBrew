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

typedef NS_ENUM(NSUInteger, OBMashCalculationType) {
  OBMashStrikeWaterCalculation,
  OBMashInfusionStepCalculation
};

@interface OBStrikeWaterViewController : GAITrackedViewController

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) OBNumericGaugeViewController *gaugeViewController;

@property (nonatomic, assign) OBMashCalculationType calculationType;

@end
