//
//  OBGaugeView.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/6/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBColorView.h"
#import <UICountingLabel/UICountingLabel.h>

@interface OBGaugeView : UIView

@property (nonatomic) IBOutlet UICountingLabel *valueLabel;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic) IBOutlet OBColorView *colorView;

@end
