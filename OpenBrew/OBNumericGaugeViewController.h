//
//  OBGaugeViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSettings.h"
#import "OBRecipe.h"
#import "OBHopAddition.h"
#import "OBGaugeView.h"

@class OBRecipe, OBColorView;

@interface OBNumericGaugeViewController : UIViewController

@property (nonatomic) id target;
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *descriptionText;
@property (nonatomic) NSString *valueFormat;

- (instancetype)initWithTarget:(id)target
                  keyToDisplay:(NSString *)key
                   valueFormat:(NSString *)valueFormat
               descriptionText:(NSString *)descriptionText;

- (void)refresh:(BOOL)animate;

@end
