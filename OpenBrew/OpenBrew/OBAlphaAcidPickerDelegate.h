//
//  OBAlphaAcidPickerDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/2/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBPickerDelegate.h"

@class OBHopAddition;
@protocol OBPickerObserver;

@interface OBAlphaAcidPickerDelegate : NSObject <OBPickerDelegate>
@property (nonatomic, strong) OBHopAddition *hopAddition;

- (id)initWithHopAddition:(OBHopAddition *)hopAddition;

- (void)updateSelectionForPicker:(UIPickerView *)picker;

@end
