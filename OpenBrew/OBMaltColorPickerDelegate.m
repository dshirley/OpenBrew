//
//  OBMaltColorPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltColorPickerDelegate.h"
#import "OBMaltAddition.h"

@interface OBMaltColorPickerDelegate()

@property (nonatomic) NSMutableArray *values;

@end

@implementation OBMaltColorPickerDelegate

- (id)initWithMaltAddition:(OBMaltAddition *)maltAddition
{
  self = [super init];

  if (self) {
    self.maltAddition = maltAddition;

    self.values = [NSMutableArray arrayWithCapacity:71];

    for (int i = 0; i < 30; i += 1) {
      [self.values addObject:@(i)];
    }

    for (int i = 30; i < 100; i+= 5) {
      [self.values addObject:@(i)];
    }

    for (int i = 100; i < 200; i+= 10) {
      [self.values addObject:@(i)];
    }

    for (int i = 200; i <= 600; i+= 25) {
      [self.values addObject:@(i)];
    }
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  NSUInteger row = 0;
  NSUInteger closestRow = row;
  NSInteger colorInLovibond = [self.maltAddition.lovibond integerValue];

  for (; row < self.values.count; row++) {
    float lovibondCurrentRow = [self.values[row] floatValue];
    float lovibondClosestRow = [self.values[closestRow] floatValue];

    if (ABS(colorInLovibond - lovibondCurrentRow) <= ABS(colorInLovibond - lovibondClosestRow)) {
      closestRow = row;
    }
  }

  [picker selectRow:closestRow inComponent:0 animated:NO];
}

- (NSInteger)lovibondForRow:(NSInteger)row
{
  return [self.values[row] integerValue];
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
  return self.values.count;
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
