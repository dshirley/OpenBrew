//
//  OBHopQuantityPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopOuncesPickerDelegate.h"
#import "OBHopAddition.h"
#import <math.h>

#define NUM_DECIMALS 10
#define MAX_QUANTITY 16

@implementation OBHopOuncesPickerDelegate

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
  float quantityInOunces = [self.hopAddition.quantityInOunces floatValue];
  NSInteger row = roundf(quantityInOunces * NUM_DECIMALS);

  if (row > [self pickerView:picker numberOfRowsInComponent:0]) {
    row = [self pickerView:picker numberOfRowsInComponent:0];
  }

  [picker selectRow:row inComponent:0 animated:NO];
}

- (float)quantityInOuncesForRow:(NSInteger)row
{
  // Example:  row 2 -> 0.2% ounces
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
  // 1 pound is the max
  return MAX_QUANTITY * NUM_DECIMALS;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  float ounces = [self quantityInOuncesForRow:row];
  return [NSString stringWithFormat:@"%.1f oz", ounces];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  float quantity = [self quantityInOuncesForRow:row];
  self.hopAddition.quantityInOunces = [NSNumber numberWithFloat:quantity];
}

@end
