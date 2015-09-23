//
//  OBHopTypePickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/20/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBHopTypePickerDelegate.h"

@interface OBHopTypePickerDelegate()
@property (nonatomic) NSArray *types;
@end

@implementation OBHopTypePickerDelegate

- (id)initWithHopAddition:(OBHopAddition *)hopAddition
{
  self = [super init];

  if (self) {
    self.hopAddition = hopAddition;
    self.types = @[ @"Pellets", @"Whole Cone" ];
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  NSInteger row = 0;

  if (OBHopTypePellet == [self.hopAddition.type integerValue]) {
    row = 0;
  } else if (OBHopTypeWhole == [self.hopAddition.type integerValue]) {
    row = 1;
  } else {
    NSAssert(NO, @"Unknown hop type: %@", self.hopAddition.type);
  }

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
  return self.types.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  return self.types[row];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  if (0 == row) {
    self.hopAddition.type = @(OBHopTypePellet);
  } else if (1 == row) {
    self.hopAddition.type = @(OBHopTypeWhole);
  } else {
    NSAssert(NO, @"Unexpected row: %@", @(row));
  }
}


@end
