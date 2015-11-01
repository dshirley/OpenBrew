//
//  OBInfusionStepTableViewDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBInfusionStepTableViewDelegate.h"
#import "OBMultiPickerTableViewCell.h"
#import "OBPickerDelegate.h"
#import "OBKvoUtils.h"

typedef NS_ENUM(NSUInteger, OBMashCalculationCell) {
  OBGrainWeight,
  OBWaterVolume,
  OBCurrentTemperature,
  OBWaterTemperature,
  OBTargetTemerature,
};

@implementation OBInfusionStepTableViewDelegate

- (instancetype)initWithGACategory:(NSString *)gaCategory
{
  self = [super initWithGACategory:gaCategory];

  if (self) {
    self.grainWeightInPounds = @(10.0);
    self.waterVolumeInGallons = @(3.5);
    self.waterTemperatureInFahrenheit = @(212);
    self.currentTemperatureInFahrenheit = @(148);
    self.targetTemperatureInFahrenheit = @(153);
  }

  return self;
}

#pragma mark Template Methods

- (NSArray *)ingredientData
{
//  return @[ @[ @(OBGrainWeight), @(OBWaterVolume), @(OBCurrentTemperature), @(OBWaterTemperature), @(OBTargetTemerature) ] ];
  return @[ @[ @(OBGrainWeight), @(OBWaterVolume) ] ,
            @[ @(OBCurrentTemperature), @(OBWaterTemperature) ],
            @[ @(OBTargetTemerature) ] ];
}

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData
{
  OBMashCalculationCell cellType = [ingredientData integerValue];

  switch (cellType) {
    case OBGrainWeight:
      cell.textLabel.text = @"Grain weight (lbs)";\
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", [self.grainWeightInPounds floatValue]];
      break;

    case OBWaterVolume:
      cell.textLabel.text = @"Water volume (gallons)";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", [self.waterVolumeInGallons floatValue]];
      break;

    case OBCurrentTemperature:
      cell.textLabel.text = @"Current mash temperature (°F)";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", [self.currentTemperatureInFahrenheit floatValue]];
      break;

    case OBWaterTemperature:
      cell.textLabel.text = @"Temperature of water to add (°F)";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", [self.waterTemperatureInFahrenheit floatValue]];
      break;

    case OBTargetTemerature:
      cell.textLabel.text = @"Target temperature (°F)";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", [self.targetTemperatureInFahrenheit floatValue]];
      break;

    default:
      NSAssert(NO, @"Unexpected cell type: %d", cellType);
      break;
  }
}

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData
{
  OBMultiPickerTableViewCell *drawerCell = (OBMultiPickerTableViewCell *)cell;
  OBMashCalculationCell cellType = [ingredientData integerValue];
  OBPickerDelegate *pickerDelegate = nil;

  switch (cellType) {
    case OBGrainWeight:
      pickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(grainWeightInPounds)];
      pickerDelegate.format = @"%.1f";
      [pickerDelegate from:0 to:30 incrementBy:0.5];
      break;

    case OBWaterVolume:
      pickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(waterVolumeInGallons)];
      pickerDelegate.format = @"%.1f";
      [pickerDelegate from:0 to:10 incrementBy:0.1];
      break;

    case OBCurrentTemperature:
      pickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(currentTemperatureInFahrenheit)];
      pickerDelegate.format = @"%.0f°";
      [pickerDelegate from:100 to:170 incrementBy:1];
      break;

    case OBWaterTemperature:
      pickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(waterTemperatureInFahrenheit)];
      pickerDelegate.format = @"%.0f°";
      [pickerDelegate from:32 to:212 incrementBy:2];
      break;

    case OBTargetTemerature:
      pickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(targetTemperatureInFahrenheit)];
      pickerDelegate.format = @"%.0f°";
      [pickerDelegate from:100 to:165 incrementBy:1];
      break;

    default:
      NSAssert(NO, @"Unexpected cell type: %d", cellType);
      break;
  }

  [drawerCell.multiPickerView removeAllPickers];
  [drawerCell.multiPickerView addPickerDelegate:pickerDelegate withTitle:@"unused title"];
}

#pragma mark UITableViewDataSource methods

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
{
  return @"";
}

#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
  if (section <= 1) {
    return 22;
  }

  return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

@end
