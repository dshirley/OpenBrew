//
//  OBMaltColorPickerDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/10/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBMaltColorPickerDelegate.h"
#import "OBMaltAddition.h"
#import <OCMock/OCMock.h>

@interface OBMaltColorPickerDelegateTest : OBBaseTestCase

@end

@implementation OBMaltColorPickerDelegateTest

- (void)testInit
{
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];
  OBMaltColorPickerDelegate *delegate = [[OBMaltColorPickerDelegate alloc] initWithMaltAddition:malt];
  XCTAssertEqual(malt, delegate.maltAddition);
}

- (void)testUpdateSelectionForPicker
{
  [self doTestUpdateSelectionForPickerExpectedRow:0 forColor:0];
  [self doTestUpdateSelectionForPickerExpectedRow:1 forColor:1];
  [self doTestUpdateSelectionForPickerExpectedRow:15 forColor:15];

  // Test some in between values
  [self doTestUpdateSelectionForPickerExpectedRow:30 forColor:32];
  [self doTestUpdateSelectionForPickerExpectedRow:31 forColor:33];
  [self doTestUpdateSelectionForPickerExpectedRow:45 forColor:105];

  // Test the max value
  [self doTestUpdateSelectionForPickerExpectedRow:70 forColor:600];

  // Test beyond the max value
  [self doTestUpdateSelectionForPickerExpectedRow:70 forColor:601];
  [self doTestUpdateSelectionForPickerExpectedRow:70 forColor:6010];
}

- (void)doTestUpdateSelectionForPickerExpectedRow:(NSInteger)row
                                         forColor:(NSInteger)color
{
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];
  OBMaltColorPickerDelegate *delegate = [[OBMaltColorPickerDelegate alloc] initWithMaltAddition:malt];
  malt.lovibond = @(color);

  id mockPicker = [OCMockObject mockForClass:UIPickerView.class];
  [[mockPicker expect] selectRow:row inComponent:0 animated:NO];

  [delegate updateSelectionForPicker:mockPicker];

  [mockPicker verify];
  [mockPicker stopMocking];
}

- (void)testNumberOfComponentsInPickerView
{
  OBMaltColorPickerDelegate *delegate = [[OBMaltColorPickerDelegate alloc] initWithMaltAddition:nil];
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);
}

- (void)testNumberOfRowsInComponent
{
  OBMaltColorPickerDelegate *delegate = [[OBMaltColorPickerDelegate alloc] initWithMaltAddition:nil];
  XCTAssertEqual(71, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(71, [delegate pickerView:nil numberOfRowsInComponent:50]);
}

- (void)testTitleForRowForComponent
{
  OBMaltColorPickerDelegate *delegate = [[OBMaltColorPickerDelegate alloc] initWithMaltAddition:nil];
  XCTAssertEqualObjects(@"0L", [delegate pickerView:nil titleForRow:0 forComponent:0]);
  XCTAssertEqualObjects(@"1L", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqualObjects(@"15L", [delegate pickerView:nil titleForRow:15 forComponent:0]);
  XCTAssertEqualObjects(@"35L", [delegate pickerView:nil titleForRow:31 forComponent:-1]);
  XCTAssertEqualObjects(@"600L", [delegate pickerView:nil titleForRow:70 forComponent:50]);
}

- (void)testDidSelectRowInComponent
{
  OBMaltAddition *malt = [self addMalt:@"Maris Otter" quantity:1.0];
  OBMaltColorPickerDelegate *delegate = [[OBMaltColorPickerDelegate alloc] initWithMaltAddition:malt];

  [delegate pickerView:nil didSelectRow:15 inComponent:0];
  XCTAssertEqual(15, [malt.lovibond integerValue]);

  [delegate pickerView:nil didSelectRow:70 inComponent:0];
  XCTAssertEqual(600, [malt.lovibond integerValue]);

  [delegate pickerView:nil didSelectRow:0 inComponent:0];
  XCTAssertEqual(0, [malt.lovibond integerValue]);
}

@end
