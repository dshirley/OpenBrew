//
//  OBMaltQuantityPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltQuantityPickerDelegate.h"
#import "OBMaltAddition.h"

#define LEFT_PICKER_COMPONENT 0
#define RIGHT_PICKER_COMPONENT 1

@implementation OBMaltQuantityPickerDelegate 

- (id)initWithMaltAddition:(OBMaltAddition *)maltAddition
{
  self = [super init];

  if (self) {
    self.maltAddition = maltAddition;
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  NSInteger baseRow = 16 * 5000;
  float pounds = [[self.maltAddition quantityInPounds] floatValue];
  float ounces = trunc((pounds - trunc(pounds)) * 16);

  [picker selectRow:(baseRow + ounces) inComponent:RIGHT_PICKER_COMPONENT animated:NO];
  [picker selectRow:(trunc(pounds)) inComponent:LEFT_PICKER_COMPONENT animated:NO];
}

#pragma mark - UIPickerViewDataSource Methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  NSInteger numRows = 0;

  switch (component) {
    case LEFT_PICKER_COMPONENT:
      numRows = 50;
      break;
    case RIGHT_PICKER_COMPONENT:
      numRows = 16 * 10000;
      break;
    default:
      assert(component < 2);
  }

  return numRows;
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)poundsForRow:(NSInteger)row
{
  return row;
}

- (NSInteger)ouncesForRow:(NSInteger)row
{
  return row % 16;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  NSString *text = nil;

  if (component == 0) {
    text = [NSString stringWithFormat:@"%ld lb", (long)[self poundsForRow:row]];
  } else {
    text = [NSString stringWithFormat:@"%ld oz", (long)[self ouncesForRow:row]];
  }

  return text;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  float currentQuantity = [self.maltAddition.quantityInPounds floatValue];

  if (component == LEFT_PICKER_COMPONENT) {

    float newPounds = (float) [self poundsForRow:row];
    float currentOunces = currentQuantity - trunc(currentQuantity);

    self.maltAddition.quantityInPounds = [NSNumber numberWithFloat:newPounds + currentOunces];

  } else if (component == RIGHT_PICKER_COMPONENT) {

    float newOunces = ((float) [self ouncesForRow:row]) / 16;
    float currentPounds = trunc(currentQuantity);

    self.maltAddition.quantityInPounds = [NSNumber numberWithFloat:currentPounds + newOunces];
  }
}

@end
