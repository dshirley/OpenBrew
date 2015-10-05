//
//  OBPickerDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/2/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBMultiPickerView.h"

@interface OBPickerDelegate : NSObject <OBPickerDelegate>

// The object whose 'key' is represented by this picker delegate
@property (nonatomic, readonly) id target;

// This key gets set on the target when the picker value changes
@property (nonatomic, readonly) NSString *key;

// The format string used to display picker rows
@property (nonatomic) NSString *format;

- (instancetype)initWithTarget:(id)target key:(NSString *)key;

- (void)from:(float)start to:(float)end incrementBy:(float)increment;

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

#import "OBHopAddition.h"

@interface OBPickerDelegate(OBHopAddition)

+ (OBPickerDelegate *)hopsQuantityInGramsPickerDelegate:(OBHopAddition *)hopAddition;

+ (OBPickerDelegate *)hopsQuantityInOuncesPickerDelegate:(OBHopAddition *)hopAddition;

+ (OBPickerDelegate *)hopsAlphaAcidPickerDelegate:(OBHopAddition *)hopAddition;

@end

#import "OBRecipe.h"

@interface OBPickerDelegate(OBRecipe)

+ (OBPickerDelegate *)volumePickerDelegate:(OBRecipe *)recipe key:(NSString *)key;

@end
