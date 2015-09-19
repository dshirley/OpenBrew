//
//  OBHopQuantityPickerDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/10/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBHopOuncesPickerDelegate.h"
#import <OCMock/OCMock.h>

@interface OBHopQuantityPickerDelegateTest : OBBaseTestCase

@end

@implementation OBHopQuantityPickerDelegateTest

- (void)testInit
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:8.0 boilTime:60];
  OBHopOuncesPickerDelegate *delegate = [[OBHopOuncesPickerDelegate alloc] initWithHopAddition:hops];
  XCTAssertEqual(hops, delegate.hopAddition);
}

- (void)testUpdateSelectionForPicker
{
  [self doTestUpdateSelectionForPickerExpectedRow:0 forQuantity:0.0];
  [self doTestUpdateSelectionForPickerExpectedRow:10 forQuantity:1.0];
  [self doTestUpdateSelectionForPickerExpectedRow:15 forQuantity:1.5];

  // Test some in between values
  [self doTestUpdateSelectionForPickerExpectedRow:15 forQuantity:1.54];
  [self doTestUpdateSelectionForPickerExpectedRow:16 forQuantity:1.55];
  [self doTestUpdateSelectionForPickerExpectedRow:16 forQuantity:1.56];

  // Test the max value
  [self doTestUpdateSelectionForPickerExpectedRow:160 forQuantity:16.0];

  // Test beyond the max value
  [self doTestUpdateSelectionForPickerExpectedRow:160 forQuantity:16.1];
}

- (void)doTestUpdateSelectionForPickerExpectedRow:(NSInteger)row
                                     forQuantity:(float)quantity
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:quantity aaPercent:8.5 boilTime:60];
  OBHopOuncesPickerDelegate *delegate = [[OBHopOuncesPickerDelegate alloc] initWithHopAddition:hops];

  id mockPicker = [OCMockObject mockForClass:UIPickerView.class];
  [[mockPicker expect] selectRow:row inComponent:0 animated:NO];

  [delegate updateSelectionForPicker:mockPicker];

  [mockPicker verify];
  [mockPicker stopMocking];
}

- (void)testNumberOfComponentsInPickerView
{
  OBHopOuncesPickerDelegate *delegate = [[OBHopOuncesPickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);
}

- (void)testNumberOfRowsInComponent
{
  OBHopOuncesPickerDelegate *delegate = [[OBHopOuncesPickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqual(160, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(160, [delegate pickerView:nil numberOfRowsInComponent:50]);
}

- (void)testTitleForRowForComponent
{
  OBHopOuncesPickerDelegate *delegate = [[OBHopOuncesPickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqualObjects(@"0.0 oz", [delegate pickerView:nil titleForRow:0 forComponent:0]);
  XCTAssertEqualObjects(@"0.1 oz", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqualObjects(@"1.6 oz", [delegate pickerView:nil titleForRow:16 forComponent:0]);
  XCTAssertEqualObjects(@"3.3 oz", [delegate pickerView:nil titleForRow:33 forComponent:-1]);
}

- (void)testDidSelectRowInComponent
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:0.0 boilTime:60];
  OBHopOuncesPickerDelegate *delegate = [[OBHopOuncesPickerDelegate alloc] initWithHopAddition:hops];

  [delegate pickerView:nil didSelectRow:160 inComponent:0];
  XCTAssertEqualWithAccuracy(16.0, [hops.quantityInOunces floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:1 inComponent:0];
  XCTAssertEqualWithAccuracy(0.1, [hops.quantityInOunces floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:0 inComponent:0];
  XCTAssertEqualWithAccuracy(0.0, [hops.quantityInOunces floatValue], 0.0001);
}

@end

