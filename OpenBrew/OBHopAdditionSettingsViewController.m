//
//  OBHopAdditionSettingsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBHopAdditionSettingsViewController.h"
#import "OBSettings.h"
#import "OBSegmentedController.h"
#import "OBKvoUtils.h"
#import "OBHopAddition.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Hop Addition Settings";

@interface OBHopAdditionSettingsViewController ()

@property (nonatomic) IBOutlet UISegmentedControl *unitsSegmentedControl;

@property (nonatomic) IBOutlet UISegmentedControl *ibuFormulaSegmentedControl;

@property (nonatomic) OBSegmentedController *unitsSettingController;
@property (nonatomic) OBSegmentedController *ibuFormulaSettingController;

@end

@implementation OBHopAdditionSettingsViewController

#pragma mark UIViewController overrides

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  self.screenName = OBGAScreenName;

  OBSettings *settings = self.settings;

  self.unitsSettingController = [[OBSegmentedController alloc]
                                 initWithSegmentedControl:self.unitsSegmentedControl
                                 googleAnalyticsAction:@"Hop Units"];

  [self.unitsSettingController addSegment:@"Ounces" actionWhenSelected:^(void) {
    settings.hopQuantityUnits = @(OBHopQuantityUnitsImperial);
  }];

  [self.unitsSettingController addSegment:@"Grams" actionWhenSelected:^(void) {
    settings.hopQuantityUnits = @(OBHopQuantityUnitsMetric);
  }];

  if (OBHopQuantityUnitsImperial == [settings.hopQuantityUnits integerValue]) {
    self.unitsSegmentedControl.selectedSegmentIndex = 0;
  } else {
    self.unitsSegmentedControl.selectedSegmentIndex = 1;
  }

  self.ibuFormulaSettingController =
    [[OBSegmentedController alloc] initWithSegmentedControl:self.ibuFormulaSegmentedControl
                                      googleAnalyticsAction:@"IBU Formula"];

  [self.ibuFormulaSettingController addSegment:@"Tinseth" actionWhenSelected:^(void) {
    settings.ibuFormula = @(OBIbuFormulaTinseth);
  }];

  [self.ibuFormulaSettingController addSegment:@"Rager" actionWhenSelected:^(void) {
    settings.ibuFormula = @(OBIbuFormulaRager);
  }];

  if (OBIbuFormulaRager == [settings.ibuFormula integerValue]) {
    self.ibuFormulaSegmentedControl.selectedSegmentIndex = 1;
  } else {
    self.ibuFormulaSegmentedControl.selectedSegmentIndex = 0;
  }
}

#pragma mark Actions

- (IBAction)greyAreaTouchDown:(id)sender {
  [self performSegueWithIdentifier:@"dismissSettingsView" sender:self];
}

@end
