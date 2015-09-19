//
//  OBHopGramsPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/19/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBHopGramsPickerDelegate.h"

#define MAX_QUANTITY 500

@implementation OBHopGramsPickerDelegate

- (id)initWithHopAddition:(OBHopAddition *)hopAddition
{
  self = [super init];

  if (self) {
    self.hopAddition = hopAddition;
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  float quantityInGrams = [self.hopAddition.quantityInGrams floatValue];
  NSInteger row = roundf(quantityInGrams);

  if (row > [self pickerView:picker numberOfRowsInComponent:0]) {
    row = [self pickerView:picker numberOfRowsInComponent:0];
  }

  [picker selectRow:row inComponent:0 animated:NO];
}

- (float)quantityInGramsForRow:(NSInteger)row
{
  return row;
}

#pragma mark - UIPickerViewDataSource Methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return MAX_QUANTITY;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  float grams = [self quantityInGramsForRow:row];
  return [NSString stringWithFormat:@"%.0f g", grams];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  float quantity = [self quantityInGramsForRow:row];
  self.hopAddition.quantityInGrams = @(quantity);
}


@end
