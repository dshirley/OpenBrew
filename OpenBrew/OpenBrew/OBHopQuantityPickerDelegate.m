//
//  OBHopQuantityPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopQuantityPickerDelegate.h"
#import "OBHopAddition.h"
#import "OBPickerObserver.h"

#define NUM_DECIMALS 10
#define MAX_QUANTITY 16

@implementation OBHopQuantityPickerDelegate

- (id)initWithHopAddition:(OBHopAddition *)hopAddition
              andObserver:(id)pickerObserver
{
  self = [super init];

  if (self) {
    self.hopAddition = hopAddition;
    self.pickerObserver = pickerObserver;
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  float quantityInOunces = [self.hopAddition.quantityInOunces floatValue];
  NSInteger row = quantityInOunces * NUM_DECIMALS;

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

  [self.pickerObserver pickerChanged];
}

@end
