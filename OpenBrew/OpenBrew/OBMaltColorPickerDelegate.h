//
//  OBMaltColorPickerDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBPickerDelegate.h"

@class OBMaltAddition;
@protocol OBPickerObserver;


@interface OBMaltColorPickerDelegate : NSObject <OBPickerDelegate>
@property (nonatomic, strong) OBMaltAddition *maltAddition;

- (id)initWithMaltAddition:(OBMaltAddition *)maltAddition;

- (void)updateSelectionForPicker:(UIPickerView *)picker;

@end
