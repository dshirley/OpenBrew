//
//  OBHopBoilTimePickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopBoilTimePickerDelegate.h"
#import "OBHopAddition.h"

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

    _referenceBoilTimes = @[ @0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10,
                             @15, @20, @30, @45, @60, @75, @90 ];
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  NSInteger row = [self.referenceBoilTimes indexOfObject:self.hopAddition.boilTimeInMinutes];

  [picker selectRow:row inComponent:0 animated:NO];
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
