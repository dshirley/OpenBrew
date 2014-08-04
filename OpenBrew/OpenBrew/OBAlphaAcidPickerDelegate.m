//
//  OBAlphaAcidPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/2/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBAlphaAcidPickerDelegate.h"
#import "OBHopAddition.h"
#import "OBPickerObserver.h"

// Allow #.# precision when selecting alpha acid percentages
#define NUM_DECIMALS 10

#define MAX_ALPHA_ACID_PERCENT 20

@implementation OBAlphaAcidPickerDelegate

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

+ (NSInteger)rowForAlphaAcidPercent:(float)alphaAcidPercent
{
  return alphaAcidPercent * NUM_DECIMALS;
}

+ (float)alphaAcidPercentForRow:(NSInteger)row
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
  return [NSString stringWithFormat:@"%.2f%%", (float)row * 0.1];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  float alphaAcid = [OBAlphaAcidPickerDelegate alphaAcidPercentForRow:row];
  self.hopAddition.alphaAcidPercent = [NSNumber numberWithFloat:alphaAcid];

  [self.pickerObserver pickerChanged];
}

@end
