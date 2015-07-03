//
//  OBMultiPickerView.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/3/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OBPickerDelegate;

@interface OBMultiPickerView : UIView

- (void)addPickerDelegate:(id<OBPickerDelegate>)pickerDelegate withTitle:(NSString *)title;
- (void)removeAllPickers;

@end


@protocol OBPickerDelegate<UIPickerViewDataSource, UIPickerViewDelegate>

// This is called to set the given pickers selected item to a given row. The row
// will correspond to whatever ingredient property the picker represents.
- (void)updateSelectionForPicker:(UIPickerView *)picker;

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

#pragma mark - UIPickerViewDelegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component;

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component;

@end