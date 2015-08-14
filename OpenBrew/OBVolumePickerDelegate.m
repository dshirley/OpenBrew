//
//  OBVolumePickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 6/9/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBVolumePickerDelegate.h"
#import "OBRecipe.h"

#define MAX_GALLONS 30

#define INCREMENT 0.25

#define NUM_PICKER_VALUES (MAX_GALLONS / INCREMENT)

@interface OBVolumePickerDelegate()
@property (nonatomic) NSString *recipePropertyName;
@end

@implementation OBVolumePickerDelegate

- (id)initWithRecipe:(OBRecipe *)recipe
  recipePropertyName:(NSString *)propertyName
{
  self = [super init];

  if (self) {
    self.recipe = recipe;
    self.recipePropertyName = propertyName;
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  float volume = [[self.recipe valueForKey:self.recipePropertyName] floatValue];
  int row = (int) round(volume / INCREMENT);

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
  return NUM_PICKER_VALUES;
}

#pragma mark - UIPickerViewDelegate

- (float)gallonsForRow:(NSInteger)row
{
  return (float) row * INCREMENT;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  return [NSString stringWithFormat:@"%.2f", [self gallonsForRow:row]];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  NSNumber *gallons = @([self gallonsForRow:row]);
  [self.recipe setValue:gallons forKey:self.recipePropertyName];
}

@end

