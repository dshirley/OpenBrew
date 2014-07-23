//
//  OBBatchSizeViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/20/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBBatchSizeViewController.h"
#import "OBRecipe.h"
#import <math.h>

#define MAX_GALLONS 20
#define NUM_FRACTIONAL_GALLONS_PER_GALLON 4
#define NUM_ROWS_IN_PICKER (MAX_GALLONS * NUM_FRACTIONAL_GALLONS_PER_GALLON)

@interface OBBatchSizeViewController ()
@property (nonatomic, weak) IBOutlet UIPickerView *picker;
@end

@implementation OBBatchSizeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  float gallons = [self.recipe.batchSizeInGallons floatValue];
  int fraction = (gallons - trunc(gallons)) * NUM_FRACTIONAL_GALLONS_PER_GALLON;

  NSInteger row = trunc(gallons) * NUM_FRACTIONAL_GALLONS_PER_GALLON + fraction - 1;

  [self.picker selectRow:row inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark UIPickerViewDataSource Methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return NUM_ROWS_IN_PICKER;
}

#pragma mark UIPickerViewDelegate Methods

- (float)valueForRow:(NSInteger)row
{
  // Don't allow zero gallons: add one to the row
  row += 1;

  float gallons = row / NUM_FRACTIONAL_GALLONS_PER_GALLON;
  float fraction = (float) (row % NUM_FRACTIONAL_GALLONS_PER_GALLON) / (float)NUM_FRACTIONAL_GALLONS_PER_GALLON;

  return gallons + fraction;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  return [NSString stringWithFormat:@"%.2f gallons", [self valueForRow:row]];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  self.recipe.batchSizeInGallons = [NSNumber numberWithFloat:[self valueForRow:row]];
}

@end
