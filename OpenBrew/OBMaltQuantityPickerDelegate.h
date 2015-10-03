//
//  OBMaltQuantityPickerDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBMultiPickerView.h"

@class OBMaltAddition;
@protocol OBPickerObserver;

@interface OBMaltQuantityPickerDelegate : NSObject <OBPickerDelegate>
@property (nonatomic) id target;
@property (nonatomic) NSString *key;

- (id)initWithTarget:(id)target key:(NSString *)propertyToSet;

- (void)updateSelectionForPicker:(UIPickerView *)picker;

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component;

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component;

@end
