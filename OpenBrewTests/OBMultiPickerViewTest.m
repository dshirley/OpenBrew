//
//  OBMultiPickerViewTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/5/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBMultiPickerView.h"
#import <OCMock/OCMock.h>

@interface OBMultiPickerView(Test)

- (UISegmentedControl *)segmentedControl;
- (UIPickerView *)picker;
- (NSMutableArray *)pickerDelegates;

- (void)setPickerDelegates:(NSArray *)delegates;

@end

@interface OBMultiPickerViewTest : XCTestCase

@end

@implementation OBMultiPickerViewTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testAwakeFromNib
{
  OBMultiPickerView *mpv = [[OBMultiPickerView alloc] initWithFrame:CGRectZero];

  [mpv awakeFromNib];

  XCTAssertNotNil(mpv.segmentedControl);
  XCTAssertEqual(0, mpv.segmentedControl.numberOfSegments);

  XCTAssertNotNil(mpv.picker);
  XCTAssertNotNil(mpv.pickerDelegates);
  XCTAssertEqual(0, mpv.pickerDelegates.count);

  XCTAssertEqual(2, mpv.subviews.count);
}

- (void)testAddPickerDelegate
{
  OBMultiPickerView *mpv = [[OBMultiPickerView alloc] initWithFrame:CGRectZero];
  [mpv awakeFromNib];

  id dummyPickerDelegate1 = [OCMockObject mockForProtocol:@protocol(OBPickerDelegate)];
  id dummyPickerDelegate2 = [OCMockObject mockForProtocol:@protocol(OBPickerDelegate)];
  id dummyPickerDelegate3 = [OCMockObject mockForProtocol:@protocol(OBPickerDelegate)];

  // Calls to the delegate should fail.
  mpv.delegate = (id)[NSNull null];

  [[dummyPickerDelegate1 expect] updateSelectionForPicker:mpv.picker];
  [mpv addPickerDelegate:dummyPickerDelegate1 withTitle:@"title1"];
  XCTAssertEqual(0, mpv.segmentedControl.selectedSegmentIndex);
  XCTAssertEqual(@"title1", [mpv.segmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects((@[ dummyPickerDelegate1 ]), mpv.pickerDelegates);
  XCTAssertEqual(dummyPickerDelegate1, mpv.picker.delegate);
  XCTAssertEqual(dummyPickerDelegate1, mpv.picker.dataSource);
  [dummyPickerDelegate1 verify];

  [[dummyPickerDelegate1 expect] updateSelectionForPicker:mpv.picker];
  [mpv addPickerDelegate:dummyPickerDelegate2 withTitle:@"title2"];
  XCTAssertEqual(0, mpv.segmentedControl.selectedSegmentIndex);
  XCTAssertEqual(@"title1", [mpv.segmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqual(@"title2", [mpv.segmentedControl titleForSegmentAtIndex:1]);
  XCTAssertEqualObjects((@[ dummyPickerDelegate1, dummyPickerDelegate2 ]), mpv.pickerDelegates);
  XCTAssertEqual(dummyPickerDelegate1, mpv.picker.delegate);
  XCTAssertEqual(dummyPickerDelegate1, mpv.picker.dataSource);
  [dummyPickerDelegate1 verify];

  [[dummyPickerDelegate1 expect] updateSelectionForPicker:mpv.picker];
  [mpv addPickerDelegate:dummyPickerDelegate3 withTitle:@"title3"];
  XCTAssertEqual(0, mpv.segmentedControl.selectedSegmentIndex);
  XCTAssertEqual(@"title1", [mpv.segmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqual(@"title2", [mpv.segmentedControl titleForSegmentAtIndex:1]);
  XCTAssertEqual(@"title3", [mpv.segmentedControl titleForSegmentAtIndex:2]);
  XCTAssertEqualObjects((@[ dummyPickerDelegate1, dummyPickerDelegate2, dummyPickerDelegate3 ]), mpv.pickerDelegates);
  XCTAssertEqual(dummyPickerDelegate1, mpv.picker.delegate);
  XCTAssertEqual(dummyPickerDelegate1, mpv.picker.dataSource);
  [dummyPickerDelegate1 verify];
}

- (void)testRemoveAllPickers
{
  OBMultiPickerView *mpv = [[OBMultiPickerView alloc] initWithFrame:CGRectZero];
  [mpv awakeFromNib];

  [mpv.segmentedControl insertSegmentWithTitle:@"title1" atIndex:0 animated:NO];
  [mpv.segmentedControl insertSegmentWithTitle:@"title2" atIndex:0 animated:NO];
  [mpv.segmentedControl insertSegmentWithTitle:@"title3" atIndex:0 animated:NO];

  [mpv setPickerDelegates:[NSMutableArray arrayWithObjects:@"dummy1", @"dummy2", nil]];

  [mpv removeAllPickers];

  XCTAssertNotNil(mpv.segmentedControl);
  XCTAssertEqual(0, mpv.segmentedControl.numberOfSegments);

  XCTAssertNotNil(mpv.pickerDelegates);
  XCTAssertEqual(0, mpv.pickerDelegates.count);
}

- (void)testSegmentSelected
{
  OBMultiPickerView *mpv = [[OBMultiPickerView alloc] initWithFrame:CGRectZero];
  [mpv awakeFromNib];

  id multiPickerMock = [OCMockObject mockForProtocol:@protocol(OBMultiPickerViewDelegate)];
  [[multiPickerMock expect] selectedPickerDidChange:1];

  id dummyPickerDelegate1 = [OCMockObject mockForProtocol:@protocol(OBPickerDelegate)];
  id dummyPickerDelegate2 = [OCMockObject mockForProtocol:@protocol(OBPickerDelegate)];
  [[dummyPickerDelegate2 expect] updateSelectionForPicker:mpv.picker];

  mpv.delegate = multiPickerMock;
  mpv.pickerDelegates = @[ dummyPickerDelegate1, dummyPickerDelegate2 ];

  [mpv.segmentedControl insertSegmentWithTitle:@"title1" atIndex:0 animated:NO];
  [mpv.segmentedControl insertSegmentWithTitle:@"title2" atIndex:1 animated:NO];
  mpv.segmentedControl.selectedSegmentIndex = 1;

  [mpv.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

  XCTAssertEqual(1, mpv.segmentedControl.selectedSegmentIndex);
  XCTAssertEqual(dummyPickerDelegate2, mpv.picker.delegate);
  XCTAssertEqual(dummyPickerDelegate2, mpv.picker.dataSource);

  [multiPickerMock verify];
  [dummyPickerDelegate2 verify];
}

- (void)testSetSelectedPicker
{
  OBMultiPickerView *mpv = [[OBMultiPickerView alloc] initWithFrame:CGRectZero];
  [mpv awakeFromNib];

  id dummyPickerDelegate1 = [OCMockObject mockForProtocol:@protocol(OBPickerDelegate)];
  id dummyPickerDelegate2 = [OCMockObject mockForProtocol:@protocol(OBPickerDelegate)];
  [[dummyPickerDelegate2 expect] updateSelectionForPicker:mpv.picker];

  mpv.delegate = (id)[NSNull null];
  mpv.pickerDelegates = @[ dummyPickerDelegate1, dummyPickerDelegate2 ];

  [mpv.segmentedControl insertSegmentWithTitle:@"title1" atIndex:0 animated:NO];
  [mpv.segmentedControl insertSegmentWithTitle:@"title2" atIndex:1 animated:NO];
  mpv.segmentedControl.selectedSegmentIndex = 1;

  [mpv setSelectedPicker:1];

  XCTAssertEqual(1, mpv.segmentedControl.selectedSegmentIndex);
  XCTAssertEqual(dummyPickerDelegate2, mpv.picker.delegate);
  XCTAssertEqual(dummyPickerDelegate2, mpv.picker.dataSource);

  [dummyPickerDelegate2 verify];
}

@end
