//
//  OBHopBoilTimePickerDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBPickerDelegate.h"

@class OBHopAddition;

@interface OBHopBoilTimePickerDelegate : NSObject <OBPickerDelegate>
@property (nonatomic, strong) OBHopAddition *hopAddition;

- (id)initWithHopAddition:(OBHopAddition *)hopAddition;

- (void)updateSelectionForPicker:(UIPickerView *)picker;

@end
