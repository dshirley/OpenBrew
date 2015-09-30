//
//  OBIbuFormulaSegmentedControlDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBSettings.h"
#import "OBBaseTestCase.h"
#import "OBIbuFormulaSegmentedControlDelegate.h"

@interface OBIbuFormulaSegmentedControlDelegateTest : OBBaseTestCase
@property (nonatomic) OBIbuFormulaSegmentedControlDelegate *delegate;
@end

@implementation OBIbuFormulaSegmentedControlDelegateTest

- (void)setUp {
  [super setUp];

  self.delegate = [[OBIbuFormulaSegmentedControlDelegate alloc] initWithSettings:self.settings];
}

- (void)testSegmentTitles
{
  XCTAssertEqualObjects((@[ @"Tinseth", @"Rager" ]), [self.delegate segmentTitlesForSegmentedControl:nil]);
}

- (void)testSegmentSelected
{
  self.settings.ibuFormula = @(OBIbuFormulaRager);

  [self.delegate segmentedControl:nil segmentSelected:0];
  XCTAssertEqualObjects(@(OBIbuFormulaTinseth), self.settings.ibuFormula);

  [self.delegate segmentedControl:nil segmentSelected:1];
  XCTAssertEqualObjects(@(OBIbuFormulaRager), self.settings.ibuFormula);
}

- (void)testInitiallySelectedSegment
{
  self.settings.ibuFormula = @(OBIbuFormulaRager);
  XCTAssertEqual(1, [self.delegate initiallySelectedSegmentForSegmentedControl:nil]);

  self.settings.ibuFormula = @(OBIbuFormulaTinseth);
  XCTAssertEqual(0, [self.delegate initiallySelectedSegmentForSegmentedControl:nil]);
}

@end
