//
//  OBMashCalculationsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/2/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMashCalculationsViewController.h"
#import "OBKvoUtils.h"
#import "OBMashCalculationTableViewCell.h"

typedef NS_ENUM(NSUInteger, OBMashCalculationCell) {
  OBGrainWeight,
  OBGrainTemperature,
  OBWaterVolume,
  OBTargetTemerature,
  OBNumberOfCells
};

// Google Analytics constants
static NSString* const OBGAScreenName = @"Mash Calculations";

@implementation OBMashCalculationsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.screenName = OBGAScreenName;

  self.gaugeView.valueLabel.text = @"--";
  self.gaugeView.descriptionLabel.text = @"Strike water temperature";
  self.gaugeView.colorView.hidden = YES;

  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];

  NSIndexPath *firstCell = [NSIndexPath indexPathForRow:0 inSection:0];
  [self selectTextInputAtIndexPath:firstCell];
}

- (void)selectTextInputAtIndexPath:(NSIndexPath *)indexPath
{
  OBMashCalculationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  [cell.inputField becomeFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textField
{
  NSString *text = textField.text;
  NSRange range = [text rangeOfString:@"."];

  if (range.location != NSNotFound &&
      [text hasSuffix:@"."] &&
      range.location != (text.length - 1))
  {
    // There's more than one decimal
    textField.text = [text substringToIndex:text.length - 1];
  }

  if (![self allFieldsAreSet]) {
    return;
  }

  float strikeWaterTemperature = [self strikeWaterTemperature];

  self.gaugeView.valueLabel.text = [NSString stringWithFormat:@"%.0f°", strikeWaterTemperature];
}

// http://www.howtobrew.com/section3/chapter16-3.html
// Strike Water Temperature Tw = (.2/r)(T2 - T1) + T2
- (float)strikeWaterTemperature
{
  float grainWeight = [self valueForRow:OBGrainWeight];
  float liquorVolumeInQuarts = [self valueForRow:OBWaterVolume] * 4;

  float t1 = [self valueForRow:OBGrainTemperature];
  float t2 = [self valueForRow:OBTargetTemerature];
  float r = liquorVolumeInQuarts / grainWeight;

  return ((.2 / r) * (t2 - t1)) + t2;
}

- (BOOL)allFieldsAreSet
{
  for (int i = 0; i < OBNumberOfCells; i++) {
    NSString *input = [self inputForRow:i];
    if (![self numberFromString:input]) {
      return NO;
    }
  }

  return YES;
}

- (NSString *)inputForRow:(NSInteger)row
{
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
  OBMashCalculationTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  return cell.inputField.text;
}

- (float)valueForRow:(NSInteger)row
{
  NSString *stringValue = [self inputForRow:row];
  return [[self numberFromString:stringValue] floatValue];
}

- (NSNumber *)numberFromString:(NSString *)string
{
  static NSNumberFormatter *formatter = nil;

  if (!formatter) {
    formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
  }

  return [formatter numberFromString:string];
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return OBNumberOfCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  OBMashCalculationTableViewCell *cell = nil;

  switch (indexPath.row) {
    case OBGrainWeight:
      cell = (id)[tableView dequeueReusableCellWithIdentifier:@"grainWeight"];
      cell.inputField.text = self.grainWeight;
      break;

    case OBGrainTemperature:
      cell = (id)[tableView dequeueReusableCellWithIdentifier:@"grainTemperature"];
      cell.inputField.text = self.grainTemperature;
      break;

    case OBWaterVolume:
      cell = (id)[tableView dequeueReusableCellWithIdentifier:@"liquorVolume"];
      cell.inputField.text = self.waterVolume;
      break;

    case OBTargetTemerature:
      cell = (id)[tableView dequeueReusableCellWithIdentifier:@"targetTemperature"];
      cell.inputField.text = self.targetTemperature;
      break;

    default:
      break;
  }

  [cell.inputField addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];

  return cell;
}

#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [self selectTextInputAtIndexPath:indexPath];
}

@end
