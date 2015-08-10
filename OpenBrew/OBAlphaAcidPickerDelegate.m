//
//  OBAlphaAcidPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/2/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBAlphaAcidPickerDelegate.h"
#import "OBHopAddition.h"
#import <math.h>

// Allow #.# precision when selecting alpha acid percentages
#define NUM_DECIMALS 10

#define MAX_ALPHA_ACID_PERCENT 20

@implementation OBAlphaAcidPickerDelegate

- (id)initWithHopAddition:(OBHopAddition *)hopAddition;
{
  self = [super init];

  if (self) {
    self.hopAddition = hopAddition;
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker {
  float alphaAcidPercent = [[self.hopAddition alphaAcidPercent] floatValue];
  NSInteger row = roundf(alphaAcidPercent * NUM_DECIMALS);

  if (row > [self pickerView:picker numberOfRowsInComponent:0]) {
    row = [self pickerView:picker numberOfRowsInComponent:0];
  }

  [picker selectRow:row inComponent:0 animated:NO];

  // If the alpha % value was in between rows, we should update the alpha %
  // value to reflect what is actually displayed on the picker.
  // The only way that this will actually change the value is if we change
  // what values are displayed by the picker in the future.
  [self pickerView:picker didSelectRow:row inComponent:0];
}

- (float)alphaAcidPercentForRow:(NSInteger)row
{
  // Example:  row 12 -> 1.2% alpha acid
  return (float) row * (1.0 / NUM_DECIMALS);
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
  // 10 = number of decimal places; 20 = max alpha acid
  return MAX_ALPHA_ACID_PERCENT * NUM_DECIMALS;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  float alphaAcid = [self alphaAcidPercentForRow:row];
  return [NSString stringWithFormat:@"%.1f%%", alphaAcid];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  float alphaAcid = [self alphaAcidPercentForRow:row];
  self.hopAddition.alphaAcidPercent = [NSNumber numberWithFloat:alphaAcid];
}

@end
