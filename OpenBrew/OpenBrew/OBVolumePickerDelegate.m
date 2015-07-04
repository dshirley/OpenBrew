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
@property (nonatomic, assign) SEL propertyGetterSelector;
@property (nonatomic, assign) SEL propertySetterSelector;
@end

@implementation OBVolumePickerDelegate

- (id)initWithRecipe:(OBRecipe *)recipe
   andPropertyGetter:(SEL)propertyGetterSelector
   andPropertySetter:(SEL)propertySetterSelector;
{
  self = [super init];

  if (self) {
    self.recipe = recipe;
    self.propertyGetterSelector = propertyGetterSelector;
    self.propertySetterSelector = propertySetterSelector;
  }

  return self;
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  // The compiler complains about a potential memory leak since the selector is unknown
  // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
  // The fix is making a cast
  IMP imp = [self.recipe methodForSelector:self.propertyGetterSelector];
  NSNumber *(*func)(id, SEL) = (void *)imp;
  float volume = [func(self.recipe, self.propertyGetterSelector) floatValue];
  int row = (int) (volume / INCREMENT);

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
  // TODO: this will need to be implemented differently for each picker.
  // For example, kettleLossage should not be allowed to be greater than the batch size

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

  // The compiler complains about a potential memory leak since the selector is unknown
  // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
  // The fix is making a cast
  IMP imp = [self.recipe methodForSelector:self.propertySetterSelector];
  void (*func)(id, SEL, NSNumber *) = (void *)imp;
  func(self.recipe, self.propertySetterSelector, gallons);
}

@end

