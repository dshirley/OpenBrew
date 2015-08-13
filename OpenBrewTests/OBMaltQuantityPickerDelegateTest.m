//
//  OBMaltQuantityPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/12/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBMaltQuantityPickerDelegate.h"
#import "OBMaltAddition.h"
#import <OCMock/OCMock.h>

@interface OBMaltQuantityPickerDelegateTest : OBBaseTestCase

@end

@implementation OBMaltQuantityPickerDelegateTest


- (void)testInit
{
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];
  OBMaltQuantityPickerDelegate *delegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:malt];
  XCTAssertEqual(malt, delegate.maltAddition);
}

- (void)testUpdateSelectionForPicker
{
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(0), @(16000)] forQuantity:0];
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(0), @(16001)] forQuantity:(1.0 / 16.0)];
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(0), @(16002)] forQuantity:(2.0 / 16.0)];
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(1), @(16002)] forQuantity:(1 + (2.0 / 16.0))];
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(5), @(16015)] forQuantity:(5 + (15.0 / 16.0))];

  // Test some in between values
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(0), @(16000)] forQuantity:(0.9 / 32.0)];
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(0), @(16001)] forQuantity:(1.0 / 32.0)];
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(0), @(16001)] forQuantity:(1.1 / 32.0)];

  // Test the max value
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(50), @(16000)] forQuantity:(50)];

  // Test beyond the max value
  [self doTestUpdateSelectionForPickerExpectedRows:@[@(55), @(16000)] forQuantity:(55)];
}

- (void)doTestUpdateSelectionForPickerExpectedRows:(NSArray *)rows
                                      forQuantity:(float)quantity
{
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];
  OBMaltQuantityPickerDelegate *delegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:malt];
  malt.quantityInPounds = @(quantity);

  id mockPicker = [OCMockObject mockForClass:UIPickerView.class];
  [[mockPicker expect] selectRow:[rows[0] integerValue] inComponent:0 animated:NO];
  [[mockPicker expect] selectRow:[rows[1] integerValue] inComponent:1 animated:NO];

  [delegate updateSelectionForPicker:mockPicker];

  [mockPicker verify];
  [mockPicker stopMocking];
}

- (void)testNumberOfComponentsInPickerView
{
  OBMaltQuantityPickerDelegate *delegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:nil];
  XCTAssertEqual(2, [delegate numberOfComponentsInPickerView:nil]);
}

- (void)testNumberOfRowsInComponent
{
  OBMaltQuantityPickerDelegate *delegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:nil];
  XCTAssertEqual(50, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(32000, [delegate pickerView:nil numberOfRowsInComponent:1]);
}

- (void)testTitleForRowForComponent
{
  OBMaltQuantityPickerDelegate *delegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:nil];
  XCTAssertEqualObjects(@"0 lb", [delegate pickerView:nil titleForRow:0 forComponent:0]);
  XCTAssertEqualObjects(@"5 lb", [delegate pickerView:nil titleForRow:5 forComponent:0]);
  XCTAssertEqualObjects(@"50 lb", [delegate pickerView:nil titleForRow:50 forComponent:0]);
  XCTAssertEqualObjects(@"500 lb", [delegate pickerView:nil titleForRow:500 forComponent:0]);

  XCTAssertEqualObjects(@"0 oz", [delegate pickerView:nil titleForRow:0 forComponent:1]);
  XCTAssertEqualObjects(@"1 oz", [delegate pickerView:nil titleForRow:1 forComponent:1]);
  XCTAssertEqualObjects(@"5 oz", [delegate pickerView:nil titleForRow:(16 * 100 + 5) forComponent:1]);
  XCTAssertEqualObjects(@"15 oz", [delegate pickerView:nil titleForRow:(16 * 10000 + 15) forComponent:1]);
  XCTAssertEqualObjects(@"0 oz", [delegate pickerView:nil titleForRow:16 forComponent:1]);
}

- (void)testDidSelectRowInComponent
{
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];
  OBMaltQuantityPickerDelegate *delegate = [[OBMaltQuantityPickerDelegate alloc] initWithMaltAddition:malt];

  [delegate pickerView:nil didSelectRow:15 inComponent:0];
  XCTAssertEqualWithAccuracy(15.0, [malt.quantityInPounds floatValue], 0.000001);

  [delegate pickerView:nil didSelectRow:16001 inComponent:1];
  XCTAssertEqualWithAccuracy(15.0625, [malt.quantityInPounds floatValue], 0.000001);

  [delegate pickerView:nil didSelectRow:16016 inComponent:1];
  XCTAssertEqualWithAccuracy(15.0, [malt.quantityInPounds floatValue], 0.000001);

  [delegate pickerView:nil didSelectRow:168 inComponent:1];
  XCTAssertEqualWithAccuracy(15.5, [malt.quantityInPounds floatValue], 0.000001);

  [delegate pickerView:nil didSelectRow:50 inComponent:0];
  XCTAssertEqualWithAccuracy(50.5, [malt.quantityInPounds floatValue], 0.000001);
}

@end
