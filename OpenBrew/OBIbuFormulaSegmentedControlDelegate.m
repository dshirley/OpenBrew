//
//  OBIbuFormulaSegmentedControlDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBIbuFormulaSegmentedControlDelegate.h"
#import "OBHopAddition.h"
#import "OBSettings.h"
#import "OBKvoUtils.h"

@implementation OBIbuFormulaSegmentedControlDelegate

- (NSArray *)titles
{
  return @[ @"Tinseth", @"Rager" ];
}

- (NSArray *)values
{
  return @[ @(OBIbuFormulaTinseth), @(OBIbuFormulaRager) ];;
}

- (NSString *)settingsKey
{
  return KVO_KEY(ibuFormula);
}

@end
