//
//  OBSettingsTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBSettings.h"

@interface OBSettingsTest : XCTestCase

@end

@implementation OBSettingsTest

- (void)testIbuFormula
{
  [OBSettings setIbuFormula:OBIbuFormulaTinseth];
  XCTAssertEqual([OBSettings ibuFormula], OBIbuFormulaTinseth);

  [OBSettings setIbuFormula:OBIbuFormulaRager];
  XCTAssertEqual([OBSettings ibuFormula], OBIbuFormulaRager);

  [OBSettings setIbuFormula:OBIbuFormulaTinseth];
  XCTAssertEqual([OBSettings ibuFormula], OBIbuFormulaTinseth);
}

@end
