//
//  OBPickerDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBPickerDelegate.h"
#import "OBKvoUtils.h"
#import <OCMock/OCMock.h>


// For easier testing of the convenience categories
@interface OBPickerDelegate(Internal)
- (float)valueForRow:(NSInteger)row;
- (NSInteger)rowForValue:(float)value;
@end

@interface OBPickerDelegateTest : OBBaseTestCase

@end

@implementation OBPickerDelegateTest

- (void)setUp {
  [super setUp];
}

- (void)testInit
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:8.0 boilTime:60];
  OBPickerDelegate *delegate = [[OBPickerDelegate alloc] initWithTarget:hops key:KVO_KEY(quantityInGrams)];
  XCTAssertEqual(hops, delegate.target);
  XCTAssertEqualObjects(KVO_KEY(quantityInGrams), delegate.key);
  [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)testUpdateSelectionForPicker
{
  [self doTestUpdateSelectionForPickerExpectedRow:0 forQuantity:0.0 from:0 to:500 increment:1];
  [self doTestUpdateSelectionForPickerExpectedRow:1 forQuantity:1.0 from:0 to:500 increment:1];
  [self doTestUpdateSelectionForPickerExpectedRow:2 forQuantity:2.0 from:0 to:500 increment:1];
  [self doTestUpdateSelectionForPickerExpectedRow:0 forQuantity:10 from:10 to:20 increment:0.1];
  [self doTestUpdateSelectionForPickerExpectedRow:1 forQuantity:10.1 from:10 to:20 increment:0.1];
  [self doTestUpdateSelectionForPickerExpectedRow:2 forQuantity:10.2 from:10 to:20 increment:0.1];
  [self doTestUpdateSelectionForPickerExpectedRow:53 forQuantity:15.3 from:10 to:20 increment:0.1];

  // Test some in between values
  [self doTestUpdateSelectionForPickerExpectedRow:1 forQuantity:1.49 from:0 to:500 increment:1];
  [self doTestUpdateSelectionForPickerExpectedRow:2 forQuantity:1.50 from:0 to:500 increment:1];
  [self doTestUpdateSelectionForPickerExpectedRow:2 forQuantity:1.51 from:0 to:500 increment:1];
  [self doTestUpdateSelectionForPickerExpectedRow:53 forQuantity:15.34 from:10 to:20 increment:0.1];
  [self doTestUpdateSelectionForPickerExpectedRow:54 forQuantity:15.35 from:10 to:20 increment:0.1];

  // Test below the minimum
  [self doTestUpdateSelectionForPickerExpectedRow:0 forQuantity:-1 from:0 to:500 increment:1];
  [self doTestUpdateSelectionForPickerExpectedRow:0 forQuantity:9.9 from:10 to:20 increment:0.1];

  // Test the max value
  [self doTestUpdateSelectionForPickerExpectedRow:500 forQuantity:500 from:0 to:500 increment:1];
  [self doTestUpdateSelectionForPickerExpectedRow:100 forQuantity:20 from:10 to:20 increment:0.1];

  // Test beyond the max value
  [self doTestUpdateSelectionForPickerExpectedRow:500 forQuantity:501 from:0 to:500 increment:1];
  [self doTestUpdateSelectionForPickerExpectedRow:100 forQuantity:20.1 from:10 to:20 increment:0.1];
}

- (void)doTestUpdateSelectionForPickerExpectedRow:(NSInteger)row
                                      forQuantity:(float)quantity
                                             from:(float)from
                                               to:(float)to
                                        increment:(float)increment
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:quantity aaPercent:8.5 boilTime:60];
  hops.quantityInGrams = @(quantity);

  OBPickerDelegate *delegate = [[OBPickerDelegate alloc] initWithTarget:hops key:KVO_KEY(quantityInGrams)];
  [delegate from:from to:to incrementBy:increment];

  id mockPicker = [OCMockObject mockForClass:UIPickerView.class];
  [[mockPicker expect] selectRow:row inComponent:0 animated:NO];

  [delegate updateSelectionForPicker:mockPicker];

  [mockPicker verify];
  [mockPicker stopMocking];
}

- (void)testNumberOfComponentsInPickerView
{
  OBPickerDelegate *delegate = [[OBPickerDelegate alloc] initWithTarget:nil key:nil];
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);
}

- (void)testNumberOfRowsInComponent
{
  OBPickerDelegate *delegate = [[OBPickerDelegate alloc] initWithTarget:nil key:nil];
  [delegate from:0 to:500 incrementBy:1];

  XCTAssertEqual(501, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(501, [delegate pickerView:nil numberOfRowsInComponent:50]);

  [delegate from:20 to:25 incrementBy:0.1];
  XCTAssertEqual(51, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(51, [delegate pickerView:nil numberOfRowsInComponent:50]);
}

- (void)testTitleForRowForComponent
{
  OBPickerDelegate *delegate = [[OBPickerDelegate alloc] initWithTarget:nil key:nil];
  [delegate from:0 to:500 incrementBy:1];
  delegate.format = @"%.0f g";

  XCTAssertEqualObjects(@"0 g", [delegate pickerView:nil titleForRow:0 forComponent:0]);
  XCTAssertEqualObjects(@"1 g", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqualObjects(@"500 g", [delegate pickerView:nil titleForRow:500 forComponent:0]);
  XCTAssertEqualObjects(@"3 g", [delegate pickerView:nil titleForRow:3 forComponent:-1]);

  [delegate from:5 to:7 incrementBy:0.25];
  delegate.format = @"%.2f";
  XCTAssertEqualObjects(@"5.00", [delegate pickerView:nil titleForRow:0 forComponent:0]);
  XCTAssertEqualObjects(@"5.25", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqualObjects(@"7.00", [delegate pickerView:nil titleForRow:8 forComponent:0]);
  XCTAssertEqualObjects(@"7.25", [delegate pickerView:nil titleForRow:9 forComponent:0]);
}

- (void)testDidSelectRowInComponent
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:0.0 boilTime:60];
  OBPickerDelegate *delegate = [[OBPickerDelegate alloc] initWithTarget:hops key:KVO_KEY(quantityInGrams)];
  [delegate from:0 to:500 incrementBy:1];

  [delegate pickerView:nil didSelectRow:500 inComponent:0];
  XCTAssertEqualWithAccuracy(500, [hops.quantityInGrams floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:1 inComponent:0];
  XCTAssertEqualWithAccuracy(1, [hops.quantityInGrams floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:0 inComponent:0];
  XCTAssertEqualWithAccuracy(0, [hops.quantityInGrams floatValue], 0.0001);

  [delegate from:10 to:15 incrementBy:0.1];

  [delegate pickerView:nil didSelectRow:0 inComponent:0];
  XCTAssertEqualWithAccuracy(10, [hops.quantityInGrams floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:50 inComponent:0];
  XCTAssertEqualWithAccuracy(15, [hops.quantityInGrams floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:49 inComponent:0];
  XCTAssertEqualWithAccuracy(14.9, [hops.quantityInGrams floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:1 inComponent:0];
  XCTAssertEqualWithAccuracy(10.1, [hops.quantityInGrams floatValue], 0.0001);
}

- (void)testHopsQuantityInOuncesPickerDelegate
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:8.0 boilTime:60];
  OBPickerDelegate *delegate = [OBPickerDelegate hopsQuantityInOuncesPickerDelegate:hops];

  XCTAssertEqual(hops, delegate.target);
  XCTAssertEqualObjects(@"quantityInOunces", delegate.key);

  XCTAssertEqualWithAccuracy(0, [delegate valueForRow:0], 0.00001);
  XCTAssertEqualWithAccuracy(.1, [delegate valueForRow:1], 0.00001);
  XCTAssertEqualWithAccuracy(16, [delegate valueForRow:160], 0.00001);

  XCTAssertEqual(0, [delegate rowForValue:0]);
  XCTAssertEqual(1, [delegate rowForValue:0.1]);
  XCTAssertEqual(160, [delegate rowForValue:16.1]);

  XCTAssertEqualObjects(@"0.1 oz", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);

  [delegate pickerView:nil didSelectRow:160 inComponent:0];
  XCTAssertEqualWithAccuracy(16.0, [hops.quantityInOunces floatValue], 0.0001);
}

- (void)testHopsQuantityInGramsPickerDelegate
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:8.0 boilTime:60];
  hops.quantityInGrams = @(10.0);

  OBPickerDelegate *delegate = [OBPickerDelegate hopsQuantityInGramsPickerDelegate:hops];

  XCTAssertEqual(hops, delegate.target);
  XCTAssertEqualObjects(@"quantityInGrams", delegate.key);

  XCTAssertEqualWithAccuracy(0, [delegate valueForRow:0], 0.00001);
  XCTAssertEqualWithAccuracy(1, [delegate valueForRow:1], 0.00001);
  XCTAssertEqualWithAccuracy(500, [delegate valueForRow:500], 0.00001);

  XCTAssertEqual(0, [delegate rowForValue:0]);
  XCTAssertEqual(0, [delegate rowForValue:0.1]);
  XCTAssertEqual(1, [delegate rowForValue:1]);
  XCTAssertEqual(500, [delegate rowForValue:5000]);

  XCTAssertEqualObjects(@"1 g", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);

  [delegate pickerView:nil didSelectRow:100 inComponent:0];
  XCTAssertEqualWithAccuracy(100, [hops.quantityInGrams floatValue], 0.0001);
}

- (void)testHopsAlphaAcidPercentPickerDelegate
{
  OBHopAddition *hops = [self addHops:@"Citra" quantity:1.0 aaPercent:8.0 boilTime:60];
  OBPickerDelegate *delegate = [OBPickerDelegate hopsAlphaAcidPickerDelegate:hops];

  XCTAssertEqual(hops, delegate.target);
  XCTAssertEqualObjects(@"alphaAcidPercent", delegate.key);

  XCTAssertEqualWithAccuracy(0, [delegate valueForRow:0], 0.00001);
  XCTAssertEqualWithAccuracy(.1, [delegate valueForRow:1], 0.00001);
  XCTAssertEqualWithAccuracy(20.0, [delegate valueForRow:200], 0.00001);

  XCTAssertEqual(0, [delegate rowForValue:0]);
  XCTAssertEqual(1, [delegate rowForValue:0.1]);
  XCTAssertEqual(200, [delegate rowForValue:20]);

  XCTAssertEqualObjects(@"1.2%", [delegate pickerView:nil titleForRow:12 forComponent:0]);
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);

  [delegate pickerView:nil didSelectRow:100 inComponent:0];
  XCTAssertEqualWithAccuracy(10.0, [hops.alphaAcidPercent floatValue], 0.0001);
}

- (void)testVolumePickerDelegate
{
  OBPickerDelegate *delegate = [OBPickerDelegate volumePickerDelegate:self.recipe key:KVO_KEY(postBoilVolumeInGallons)];

  XCTAssertEqual(self.recipe, delegate.target);
  XCTAssertEqualObjects(@"postBoilVolumeInGallons", delegate.key);

  XCTAssertEqualWithAccuracy(0, [delegate valueForRow:0], 0.00001);
  XCTAssertEqualWithAccuracy(.25, [delegate valueForRow:1], 0.00001);
  XCTAssertEqualWithAccuracy(30.0, [delegate valueForRow:120], 0.00001);

  XCTAssertEqual(0, [delegate rowForValue:0]);
  XCTAssertEqual(1, [delegate rowForValue:0.25]);
  XCTAssertEqual(120, [delegate rowForValue:30]);

  XCTAssertEqualObjects(@"0.25", [delegate pickerView:nil titleForRow:1 forComponent:0]);
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);

  [delegate pickerView:nil didSelectRow:100 inComponent:0];
  XCTAssertEqualWithAccuracy(25.0, [self.recipe.postBoilVolumeInGallons floatValue], 0.0001);
}

@end
