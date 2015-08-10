//
//  OBHopBoilTimePickerDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBHopBoilTimePickerDelegate.h"
#import "OBHopAddition.h"
#import <OCMock/OCMock.h>

@interface OBHopBoilTimePickerDelegateTest : OBBaseTestCase

@end

@implementation OBHopBoilTimePickerDelegateTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testInitWithHopAddition
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:9.5 boilTime:60];
  OBHopBoilTimePickerDelegate *delegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:hops];

  XCTAssertEqual(hops, delegate.hopAddition);
}

- (void)testNumberOfComponentsInPickerView
{
  OBHopBoilTimePickerDelegate *delegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);
}

- (void)testNumberOfRowsInComponent
{
  OBHopBoilTimePickerDelegate *delegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:nil];
  XCTAssertEqual(19, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(19, [delegate pickerView:nil numberOfRowsInComponent:50]);
}

- (void)testTitleForRowForComponent
{
  OBHopBoilTimePickerDelegate *delegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:nil];

  XCTAssertEqualObjects(@"0 min", [delegate pickerView:nil titleForRow:0 forComponent:0]);
  XCTAssertEqualObjects(@"1 min", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqualObjects(@"2 min", [delegate pickerView:nil titleForRow:2 forComponent:0]);

  NSInteger max = [delegate pickerView:nil numberOfRowsInComponent:0] - 1;
  XCTAssertEqualObjects(@"90 min", [delegate pickerView:nil titleForRow:max forComponent:0]);
}

- (void)testDidSelectRowInComponent
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:9.5 boilTime:60];
  OBHopBoilTimePickerDelegate *delegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:hops];

  [delegate pickerView:nil didSelectRow:1 inComponent:0];
  XCTAssertEqualObjects(@(1), hops.boilTimeInMinutes);

  [delegate pickerView:nil didSelectRow:0 inComponent:0];
  XCTAssertEqualObjects(@(0), hops.boilTimeInMinutes);

  NSInteger max = [delegate pickerView:nil numberOfRowsInComponent:0] - 1;
  [delegate pickerView:nil didSelectRow:max inComponent:0];
  XCTAssertEqualObjects(@(90), hops.boilTimeInMinutes);
}

- (void)testUpdateSelectionForPicker
{
  [self doTestUpdateSelectionForPickerExpectedRow:0 forBoilTime:0];
  [self doTestUpdateSelectionForPickerExpectedRow:1 forBoilTime:1.0];

  // Test some in between values
  // The only way we can reach one of these states is if we change the values that
  // get displayed in the picker in a future version
  [self doTestUpdateSelectionForPickerExpectedRow:6 forBoilTime:11];
  [self doTestUpdateSelectionForPickerExpectedRow:7 forBoilTime:13];
  [self doTestUpdateSelectionForPickerExpectedRow:9 forBoilTime:23];
  [self doTestUpdateSelectionForPickerExpectedRow:10 forBoilTime:31];
  [self doTestUpdateSelectionForPickerExpectedRow:12 forBoilTime:38];
  [self doTestUpdateSelectionForPickerExpectedRow:13 forBoilTime:46];
  [self doTestUpdateSelectionForPickerExpectedRow:15 forBoilTime:56];
  [self doTestUpdateSelectionForPickerExpectedRow:16 forBoilTime:65];
  [self doTestUpdateSelectionForPickerExpectedRow:17 forBoilTime:74];
  [self doTestUpdateSelectionForPickerExpectedRow:17 forBoilTime:76];
  [self doTestUpdateSelectionForPickerExpectedRow:18 forBoilTime:85];

  // Test beyond the max value
  [self doTestUpdateSelectionForPickerExpectedRow:18 forBoilTime:300];
}

- (void)doTestUpdateSelectionForPickerExpectedRow:(NSInteger)row
                                     forBoilTime:(float)boilTime
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:10.0 boilTime:boilTime];
  OBHopBoilTimePickerDelegate *delegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:hops];

  id mockPicker = [OCMockObject mockForClass:UIPickerView.class];
  [[mockPicker expect] selectRow:row inComponent:0 animated:NO];

  [delegate updateSelectionForPicker:mockPicker];

  [mockPicker verify];
  [mockPicker stopMocking];
}


@end
