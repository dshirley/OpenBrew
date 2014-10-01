//
//  OBInstrumentGauge.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/7/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBIngredientGauge : UIView

@property (nonatomic, readonly, strong) UILabel *valueLabel;
@property (nonatomic, readonly, strong) UILabel *descriptionLabel;

@end
