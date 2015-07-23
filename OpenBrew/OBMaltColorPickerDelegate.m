//
//  OBMaltColorPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltColorPickerDelegate.h"
#import "OBMaltAddition.h"

#define MAX_DEGREES_LOVIBOND 600

@implementation OBMaltColorPickerDelegate

- (id)initWithMaltAddition:(OBMaltAddition *)maltAddition
{
  self = [super init];

  if (self) {
    self.maltAddition = maltAddition;
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker {
  NSInteger colorInLovibond = [self.maltAddition.lovibond integerValue];

  [picker selectRow:colorInLovibond inComponent:0 animated:NO];
}

- (NSInteger)lovibondForRow:(NSInteger)row
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
  return MAX_DEGREES_LOVIBOND;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  NSInteger lovibond = [self lovibondForRow:row];
  return [NSString stringWithFormat:@"%dL", (int)lovibond];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  NSInteger lovibond = [self lovibondForRow:row];
  self.maltAddition.lovibond = @(lovibond);
}

@end
