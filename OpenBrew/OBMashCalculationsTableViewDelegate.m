//
//  OBMashCalculationsTableViewDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMashCalculationsTableViewDelegate.h"
#import "OBMultiPickerTableViewCell.h"
#import "OBPickerDelegate.h"
#import "OBKvoUtils.h"

@interface OBMashCalculationsTableViewDelegate()
@property (nonatomic) NSArray *cells;
@end

@implementation OBMashCalculationsTableViewDelegate

- (instancetype)initWithCells:(NSArray *)cells gaCategory:(NSString *)gaCategory
{
  self = [super initWithGACategory:gaCategory];

  if (self) {
    self.cells = cells;
    self.grainWeightInPounds = @(10.0);
    self.grainTemperatureInFahrenheit = @(70.0);
    self.waterVolumeInGallons = @(3.5);
    self.targetTemperatureInFahrenheit = @(153);
  }

  return self;
}

#pragma mark Template Methods

- (NSArray *)ingredientData
{
  return @[ self.cells ];
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

    case OBGrainTemperature:
      cell.textLabel.text = @"Grain temperature (°F)";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", [self.grainTemperatureInFahrenheit floatValue]];
      break;

    case OBWaterVolume:
      cell.textLabel.text = @"Water volume (gallons)";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", [self.waterVolumeInGallons floatValue]];
      break;

    case OBTargetTemerature:
      cell.textLabel.text = @"Target temperature (°F)";
      cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", [self.targetTemperatureInFahrenheit floatValue]];
      break;

    default:
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

    case OBGrainTemperature:
      pickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(grainTemperatureInFahrenheit)];
      pickerDelegate.format = @"%.0f°";
      [pickerDelegate from:0 to:90 incrementBy:1];
      break;

    case OBWaterVolume:
      pickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(waterVolumeInGallons)];
      pickerDelegate.format = @"%.1f";
      [pickerDelegate from:0 to:10 incrementBy:0.1];
      break;

    case OBTargetTemerature:
      pickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(targetTemperatureInFahrenheit)];
      pickerDelegate.format = @"%.0f°";
      [pickerDelegate from:130 to:165 incrementBy:1];
      break;

    default:
      break;
  }

  [drawerCell.multiPickerView removeAllPickers];
  [drawerCell.multiPickerView addPickerDelegate:pickerDelegate withTitle:@"unused title"];
}

@end
