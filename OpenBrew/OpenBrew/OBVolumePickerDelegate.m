//
//  OBVolumePickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 6/9/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBVolumePickerDelegate.h"
#import "OBRecipe.h"
#import "OBPickerObserver.h"

// Allow #.# precision when selecting volume
#define NUM_DECIMALS 10

#define MAX_GALLONS 10

static const float pickerValues[] = {
  0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75,
  2.0, 2.5, 3,0, 3.5, 4.0, 4.5, 5.0,
  6.0, 7.0, 8.0, 10.0 };

#define NUM_PICKER_VALUES (sizeof(pickerValues) / sizeof(float))

@interface OBVolumePickerDelegate()
@property (nonatomic, assign) SEL propertyGetterSelector;
@property (nonatomic, assign) SEL propertySetterSelector;
@end

@implementation OBVolumePickerDelegate

- (id)initWithRecipe:(OBRecipe *)recipe
   andPropertyGetter:(SEL)propertyGetterSelector
   andPropertySetter:(SEL)propertySetterSelector
         andObserver:(id)updateObserver
{
  self = [super init];

  for (int i = 0; i < NUM_PICKER_VALUES; i++) {
    NSLog(@"%f", pickerValues[i]);
  }

  if (self) {
    self.recipe = recipe;
    self.propertyGetterSelector = propertyGetterSelector;
    self.propertySetterSelector = propertySetterSelector;
    self.pickerObserver = updateObserver;
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
  int row = 0;

  for (int i = 0; i < NUM_PICKER_VALUES; i++) {
    if (volume == pickerValues[i]) {
      row = i;
      break;
    }
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
  // TODO: this will need to be implemented differently for each picker.
  // For example, kettleLossage should not be allowed to be greater than the batch size

  return NUM_PICKER_VALUES;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  return [NSString stringWithFormat:@"%.2f", pickerValues[row]];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  NSNumber *gallons = @(pickerValues[row]);

  // The compiler complains about a potential memory leak since the selector is unknown
  // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
  // The fix is making a cast
  IMP imp = [self.recipe methodForSelector:self.propertySetterSelector];
  void (*func)(id, SEL, NSNumber *) = (void *)imp;
  func(self.recipe, self.propertySetterSelector, gallons);

  [self.pickerObserver pickerChanged];
}

@end

