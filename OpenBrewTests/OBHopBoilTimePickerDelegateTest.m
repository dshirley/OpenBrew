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
  XCTAssertEqual(18, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(18, [delegate pickerView:nil numberOfRowsInComponent:50]);
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
  id mockPicker = [OCMockObject mockForClass:UIPickerView.class];
  [[mockPicker expect] selectRow:1 inComponent:0 animated:NO];

  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:9.5 boilTime:1];
  OBHopBoilTimePickerDelegate *delegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:hops];

  [delegate updateSelectionForPicker:mockPicker];

  [mockPicker verify];
}



@end
