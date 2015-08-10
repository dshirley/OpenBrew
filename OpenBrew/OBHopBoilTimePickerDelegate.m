//
//  OBHopBoilTimePickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopBoilTimePickerDelegate.h"
#import "OBHopAddition.h"
#import <math.h>

#define NUM_DECIMALS 1
#define MAX_BOIL_TIME 91

@interface OBHopBoilTimePickerDelegate()
@property (nonatomic, retain) NSArray *referenceBoilTimes;
@end

@implementation OBHopBoilTimePickerDelegate

- (id)initWithHopAddition:(OBHopAddition *)hopAddition
{
  self = [super init];

  if (self) {
    _hopAddition = hopAddition;

    _referenceBoilTimes = @[ @0, @1, @2, @3, @4, @5, @10, @15, @20, @25, @30, @35, @40, @45, @50, @55, @60, @75, @90 ];
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  NSUInteger row = 0;
  NSUInteger closestRow = row;
  float hopBoilTime = [self.hopAddition.boilTimeInMinutes floatValue];

  for (; row < self.referenceBoilTimes.count; row++) {
    float boilTimeCurrentRow = [self.referenceBoilTimes[row] floatValue];
    float boilTimeClosestRow = [self.referenceBoilTimes[closestRow] floatValue];

    if (ABS(hopBoilTime - boilTimeCurrentRow) <= ABS(hopBoilTime - boilTimeClosestRow)) {
      closestRow = row;
    }
  }

  [picker selectRow:closestRow inComponent:0 animated:NO];
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
  return [self.referenceBoilTimes count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  return [NSString stringWithFormat:@"%@ min", self.referenceBoilTimes[row]];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  self.hopAddition.boilTimeInMinutes = self.referenceBoilTimes[row];
}

@end
