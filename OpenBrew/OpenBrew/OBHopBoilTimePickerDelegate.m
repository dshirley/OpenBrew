//
//  OBHopBoilTimePickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopBoilTimePickerDelegate.h"
#import "OBHopAddition.h"
#import "OBPickerObserver.h"

#define NUM_DECIMALS 1
#define MAX_BOIL_TIME 91

@implementation OBHopBoilTimePickerDelegate

- (id)initWithHopAddition:(OBHopAddition *)hopAddition
              andObserver:(id)updateObserver;
{
  self = [super init];

  if (self) {
    self.hopAddition = hopAddition;
    self.pickerObserver = updateObserver;
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  float boilTime = [self.hopAddition.boilTimeInMinutes floatValue];
  NSInteger row = boilTime * NUM_DECIMALS;

  [picker selectRow:row inComponent:0 animated:NO];
}

- (float)valueForRow:(NSInteger)row
{
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
  return MAX_BOIL_TIME * NUM_DECIMALS;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  float hours = [self valueForRow:row];
  return [NSString stringWithFormat:@"%d min", (int) hours];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  float boilTime = [self valueForRow:row];
  self.hopAddition.boilTimeInMinutes = [NSNumber numberWithFloat:boilTime];

  [self.pickerObserver pickerChanged];
}

@end
