//
//  OBVolumePickerDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 6/9/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//
//  This class allows choosing amongs various volumes of beer.
//  It takes a generic "propertySelector" so that the picker can used for
//  modifying various attributes of a recipe object.  This will work fine as long
//  as it isn't necessary to cap the values of some properties based on constraints
//  imposed by other properties. For example:  kettleLossage should probably be
//  smaller than the final beer volume.  I fear that imposing these constraints,
//  may lead to an odd user experience if the user decides to set kettleLossage
//  before the "finalBeerVolume".
//

#import <Foundation/Foundation.h>
#import "OBMultiPickerView.h"

@protocol OBPickerObserver;
@class OBRecipe;

@interface OBVolumePickerDelegate : NSObject <OBPickerDelegate>

@property (nonatomic, strong) OBRecipe *recipe;

- (id)initWithRecipe:(OBRecipe *)recipe
  recipePropertyName:(NSString *)propertyName;

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
