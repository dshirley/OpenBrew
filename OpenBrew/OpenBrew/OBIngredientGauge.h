//
//  OBInstrumentGauge.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/7/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBIngredientGauge : UIView

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)setColorInSrm:(uint32_t)srm;
- (uint32_t)colorInSrm;

@end
