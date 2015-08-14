//
//  OBVolumePickerDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/13/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBVolumePickerDelegate.h"
#import "OBMaltAddition.h"
#import <OCMock/OCMock.h>

@interface OBVolumePickerDelegateTest : OBBaseTestCase

@end

@implementation OBVolumePickerDelegateTest

- (void)testInit
{
  OBVolumePickerDelegate *delegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                                 recipePropertyName:@"postBoilVolumeInGallons"];

  XCTAssertEqual(self.recipe, delegate.recipe);
}

- (void)testUpdateSelectionForPicker
{
  [self doTestUpdateSelectionForPickerExpectedRow:0 forVolume:0.0 recipeProperty:@"postBoilVolumeInGallons"];
  [self doTestUpdateSelectionForPickerExpectedRow:4 forVolume:1.0 recipeProperty:@"postBoilVolumeInGallons"];
  [self doTestUpdateSelectionForPickerExpectedRow:5 forVolume:1.25 recipeProperty:@"postBoilVolumeInGallons"];

  [self doTestUpdateSelectionForPickerExpectedRow:0 forVolume:0.0 recipeProperty:@"preBoilVolumeInGallons"];
  [self doTestUpdateSelectionForPickerExpectedRow:4 forVolume:1.0 recipeProperty:@"preBoilVolumeInGallons"];
  [self doTestUpdateSelectionForPickerExpectedRow:5 forVolume:1.25 recipeProperty:@"preBoilVolumeInGallons"];

  // Test some in between values
  [self doTestUpdateSelectionForPickerExpectedRow:0 forVolume:0.001 recipeProperty:@"postBoilVolumeInGallons"];
  [self doTestUpdateSelectionForPickerExpectedRow:0 forVolume:0.001 recipeProperty:@"preBoilVolumeInGallons"];
  [self doTestUpdateSelectionForPickerExpectedRow:23 forVolume:5.65 recipeProperty:@"postBoilVolumeInGallons"];
  [self doTestUpdateSelectionForPickerExpectedRow:23 forVolume:5.65 recipeProperty:@"preBoilVolumeInGallons"];

  // Test the max value
  [self doTestUpdateSelectionForPickerExpectedRow:120 forVolume:30.0 recipeProperty:@"postBoilVolumeInGallons"];
  [self doTestUpdateSelectionForPickerExpectedRow:120 forVolume:30.0 recipeProperty:@"preBoilVolumeInGallons"];

  // Test beyond the max value
  [self doTestUpdateSelectionForPickerExpectedRow:1200 forVolume:300.1 recipeProperty:@"postBoilVolumeInGallons"];
  [self doTestUpdateSelectionForPickerExpectedRow:1200 forVolume:300.1 recipeProperty:@"preBoilVolumeInGallons"];
}

- (void)doTestUpdateSelectionForPickerExpectedRow:(NSInteger)row
                                        forVolume:(float)volume
                                   recipeProperty:(NSString *)recipeProperty
{
  OBVolumePickerDelegate *delegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                                 recipePropertyName:recipeProperty];

  [self.recipe setValue:@(volume) forKey:recipeProperty];

  id mockPicker = [OCMockObject mockForClass:UIPickerView.class];
  [[mockPicker expect] selectRow:row inComponent:0 animated:NO];

  [delegate updateSelectionForPicker:mockPicker];

  [mockPicker verify];
  [mockPicker stopMocking];
}

- (void)testNumberOfComponentsInPickerView
{
  OBVolumePickerDelegate *delegate = [[OBVolumePickerDelegate alloc] initWithRecipe:nil recipePropertyName:nil];
  XCTAssertEqual(1, [delegate numberOfComponentsInPickerView:nil]);
}

- (void)testNumberOfRowsInComponent
{
  OBVolumePickerDelegate *delegate = [[OBVolumePickerDelegate alloc] initWithRecipe:nil recipePropertyName:nil];
  XCTAssertEqual(120, [delegate pickerView:nil numberOfRowsInComponent:0]);
  XCTAssertEqual(120, [delegate pickerView:nil numberOfRowsInComponent:50]);
}

- (void)testTitleForRowForComponent
{
  OBVolumePickerDelegate *delegate = [[OBVolumePickerDelegate alloc] initWithRecipe:nil recipePropertyName:nil];
  XCTAssertEqualObjects(@"0.00", [delegate pickerView:nil titleForRow:0 forComponent:0]);
  XCTAssertEqualObjects(@"0.50", [delegate pickerView:nil titleForRow:2 forComponent:0]);
  XCTAssertEqualObjects(@"1.25", [delegate pickerView:nil titleForRow:5 forComponent:0]);
  XCTAssertEqualObjects(@"30.00", [delegate pickerView:nil titleForRow:120 forComponent:0]);
  XCTAssertEqualObjects(@"30.75", [delegate pickerView:nil titleForRow:123 forComponent:0]);
}

- (void)testDidSelectRowInComponent
{
  OBVolumePickerDelegate *delegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                                                 recipePropertyName:@"postBoilVolumeInGallons"];

  [delegate pickerView:nil didSelectRow:20 inComponent:0];
  XCTAssertEqualWithAccuracy(5.0, [self.recipe.postBoilVolumeInGallons floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:0 inComponent:0];
  XCTAssertEqualWithAccuracy(0.0, [self.recipe.postBoilVolumeInGallons floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:123 inComponent:0];
  XCTAssertEqualWithAccuracy(30.75, [self.recipe.postBoilVolumeInGallons floatValue], 0.0001);

  delegate = [[OBVolumePickerDelegate alloc] initWithRecipe:self.recipe
                                         recipePropertyName:@"preBoilVolumeInGallons"];

  [delegate pickerView:nil didSelectRow:20 inComponent:0];
  XCTAssertEqualWithAccuracy(5.0, [self.recipe.preBoilVolumeInGallons floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:0 inComponent:0];
  XCTAssertEqualWithAccuracy(0.0, [self.recipe.preBoilVolumeInGallons floatValue], 0.0001);

  [delegate pickerView:nil didSelectRow:123 inComponent:0];
  XCTAssertEqualWithAccuracy(30.75, [self.recipe.preBoilVolumeInGallons floatValue], 0.0001);}

@end
