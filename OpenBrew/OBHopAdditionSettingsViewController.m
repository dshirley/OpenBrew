//
//  OBHopAdditionSettingsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBHopAdditionSettingsViewController.h"
#import "OBSettings.h"
#import "OBKvoUtils.h"
#import "OBHopAddition.h"
#import "OBHopWeightSegmentedControlDelegate.h"
#import "OBIbuFormulaSegmentedControlDelegate.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Hop Addition Settings";

@interface OBHopAdditionSettingsViewController ()
@property (nonatomic) OBIbuFormulaSegmentedControlDelegate *ibuFormulatSegmentedControlDelegate;
@end

@implementation OBHopAdditionSettingsViewController

- (instancetype)initWithSettings:(OBSettings *)settings
{
  self = [super initWithNibName:@"OBHopAdditionSettingsViewController"
                         bundle:[NSBundle mainBundle]];

  if (self) {
    self.settings = settings;
  }

  return self;
}

#pragma mark UIViewController overrides

- (void)viewDidLoad
{
  [super viewDidLoad];

  // TODO: delete OBHopWeightSegmentedControlDelegate once its been consolidated into the main view segmented controller

  self.ibuFormulatSegmentedControlDelegate = [[OBIbuFormulaSegmentedControlDelegate alloc] initWithSettings:self.settings];
  self.ibuFormulaSegmentedControl.gaCategory = OBGAScreenName;
  self.ibuFormulaSegmentedControl.delegate = self.ibuFormulatSegmentedControlDelegate;

  self.screenName = OBGAScreenName;
}

@end
