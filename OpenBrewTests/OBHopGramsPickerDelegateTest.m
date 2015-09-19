//
//  OBHopGramsPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/19/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBHopGramsPickerDelegate.h"
#import <OCMock/OCMock.h>

@interface OBHopGramsPickerDelegateTest : OBBaseTestCase

@end

@implementation OBHopGramsPickerDelegateTest

- (void)testInit
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:8.0 boilTime:60];
  OBHopGramsPickerDelegate *delegate = [[OBHopGramsPickerDelegate alloc] initWithHopAddition:hops];
  XCTAssertEqual(hops, delegate.hopAddition);
}

- (void)testUpdateSelectionForPicker
{
  [self doTestUpdateSelectionForPickerExpectedRow:0 forQuantity:0.0];
  [self doTestUpdateSelectionForPickerExpectedRow:1 forQuantity:1.0];
  [self doTestUpdateSelectionForPickerExpectedRow:2 forQuantity:2.0];

  // Test some in between values
  [self doTestUpdateSelectionForPickerExpectedRow:1 forQuantity:1.49];
  [self doTestUpdateSelectionForPickerExpectedRow:2 forQuantity:1.50];
  [self doTestUpdateSelectionForPickerExpectedRow:2 forQuantity:1.51];

  // Test the max value
  [self doTestUpdateSelectionForPickerExpectedRow:500 forQuantity:500];

  // Test beyond the max value
  [self doTestUpdateSelectionForPickerExpectedRow:500 forQuantity:501];
}

- (void)doTestUpdateSelectionForPickerExpectedRow:(NSInteger)row
                                      forQuantity:(float)quantity
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:quantity aaPercent:8.5 boilTime:60];
  hops.quantityInGrams = @(quantity);

  OBHopGramsPickerDelegate *delegate = [[OBHopGramsPickerDelegate alloc] initWithHopAddition:hops];

  id mockPicker = [OCMockObject mockForClass:UIPickerView.class];
  [[mockPicker expect] selectRow:row inComponent:0 animated:NO];

  [delegate updateSelectionForPicker:mockPicker];

  [mockPicker verify];
  [mockPicker stopMocking];
}

- (void)testNumberOfComponentsInPickerView
{
  OBHopGramsPickerDelegate *delegate = [[OBHopGramsPickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);
}

- (void)testNumberOfRowsInComponent
{
  OBHopGramsPickerDelegate *delegate = [[OBHopGramsPickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqual(500, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(500, [delegate pickerView:nil numberOfRowsInComponent:50]);
}

- (void)testTitleForRowForComponent
{
  OBHopGramsPickerDelegate *delegate = [[OBHopGramsPickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqualObjects(@"0 g", [delegate pickerView:nil titleForRow:0 forComponent:0]);
  XCTAssertEqualObjects(@"1 g", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqualObjects(@"500 g", [delegate pickerView:nil titleForRow:500 forComponent:0]);
  XCTAssertEqualObjects(@"3 g", [delegate pickerView:nil titleForRow:3 forComponent:-1]);
}

- (void)testDidSelectRowInComponent
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:0.0 boilTime:60];
  OBHopGramsPickerDelegate *delegate = [[OBHopGramsPickerDelegate alloc] initWithHopAddition:hops];

  [delegate pickerView:nil didSelectRow:500 inComponent:0];
  XCTAssertEqualWithAccuracy(500, [hops.quantityInGrams floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:1 inComponent:0];
  XCTAssertEqualWithAccuracy(1, [hops.quantityInGrams floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:0 inComponent:0];
  XCTAssertEqualWithAccuracy(0, [hops.quantityInGrams floatValue], 0.0001);
}

@end
