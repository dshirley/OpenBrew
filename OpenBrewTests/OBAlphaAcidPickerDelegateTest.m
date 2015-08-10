//
//  OBAlphaAcidPickerDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/10/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBAlphaAcidPickerDelegate.h"
#import "OBHopAddition.h"
#import <OCMock/OCMock.h>

@interface OBAlphaAcidPickerDelegateTest : OBBaseTestCase

@end

@implementation OBAlphaAcidPickerDelegateTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testInit
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:8.0 boilTime:60];
  OBAlphaAcidPickerDelegate *delegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:hops];
  XCTAssertEqual(hops, delegate.hopAddition);
}

- (void)testUpdateSelectionForPicker
{
  [self doTestUpdateSelectionForPickerExpectedRow:0 forAlphaAcid:0.0 newAlphaAcid:0.0];
  [self doTestUpdateSelectionForPickerExpectedRow:10 forAlphaAcid:1.0 newAlphaAcid:1.0];
  [self doTestUpdateSelectionForPickerExpectedRow:15 forAlphaAcid:1.5 newAlphaAcid:1.5];

  // Test some in between values
  [self doTestUpdateSelectionForPickerExpectedRow:15 forAlphaAcid:1.54 newAlphaAcid:1.5];
  [self doTestUpdateSelectionForPickerExpectedRow:16 forAlphaAcid:1.55 newAlphaAcid:1.6];
  [self doTestUpdateSelectionForPickerExpectedRow:16 forAlphaAcid:1.56 newAlphaAcid:1.6];

    // Test the max value
  [self doTestUpdateSelectionForPickerExpectedRow:200 forAlphaAcid:20.0 newAlphaAcid:20.0];

  // Test beyond the max value
  [self doTestUpdateSelectionForPickerExpectedRow:200 forAlphaAcid:25 newAlphaAcid:20.0];
}

- (void)doTestUpdateSelectionForPickerExpectedRow:(NSInteger)row
                                     forAlphaAcid:(float)alphaAcid
                                     newAlphaAcid:(float)newAlphaAcid
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:alphaAcid boilTime:60];
  OBAlphaAcidPickerDelegate *delegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:hops];

  id mockPicker = [OCMockObject mockForClass:UIPickerView.class];
  [[mockPicker expect] selectRow:row inComponent:0 animated:NO];

  [delegate updateSelectionForPicker:mockPicker];

  [mockPicker verify];
  [mockPicker stopMocking];

  XCTAssertEqualWithAccuracy([hops.alphaAcidPercent floatValue], newAlphaAcid, 0.00001);
}

- (void)testNumberOfComponentsInPickerView
{
  OBAlphaAcidPickerDelegate *delegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);
}

- (void)testNumberOfRowsInComponent
{
  OBAlphaAcidPickerDelegate *delegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqual(200, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(200, [delegate pickerView:nil numberOfRowsInComponent:50]);
}

- (void)testTitleForRowForComponent
{
  OBAlphaAcidPickerDelegate *delegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqualObjects(@"0.0%", [delegate pickerView:nil titleForRow:0 forComponent:0]);
  XCTAssertEqualObjects(@"0.1%", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqualObjects(@"1.5%", [delegate pickerView:nil titleForRow:15 forComponent:0]);
  XCTAssertEqualObjects(@"19.9%", [delegate pickerView:nil titleForRow:199 forComponent:-1]);
  XCTAssertEqualObjects(@"20.0%", [delegate pickerView:nil titleForRow:200 forComponent:50]);
}

- (void)testDidSelectRowInComponent
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:0.0 boilTime:60];
  OBAlphaAcidPickerDelegate *delegate = [[OBAlphaAcidPickerDelegate alloc] initWithHopAddition:hops];

  [delegate pickerView:nil didSelectRow:200 inComponent:0];
  XCTAssertEqualWithAccuracy(20.0, [hops.alphaAcidPercent floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:103 inComponent:0];
  XCTAssertEqualWithAccuracy(10.3, [hops.alphaAcidPercent floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:0 inComponent:0];
  XCTAssertEqualWithAccuracy(0.0, [hops.alphaAcidPercent floatValue], 0.0001);
}

@end
