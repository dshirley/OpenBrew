//
//  OBBatchSizeTableViewDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBBatchSizeTableViewDelegate.h"
#import "OBMultiPickerTableViewCell.h"
#import "OBMultiPickerView.h"
#import <OCMock/OCMock.h>

@interface OBBatchSizeTableViewDelegateTest : OBBaseTestCase
@property (nonatomic) OBBatchSizeTableViewDelegate *delegate;
@property (nonatomic) UITableView *tableView;
@end

@implementation OBBatchSizeTableViewDelegateTest

- (void)setUp {
  [super setUp];

  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];

  self.delegate = [[OBBatchSizeTableViewDelegate alloc] initWithRecipe:self.recipe
                                                          andTableView:self.tableView
                                                         andGACategory:@"OBBatchSizeTableViewDelegateTest"];

  XCTAssertEqual(self.recipe, self.delegate.recipe);
  XCTAssertEqual(self.tableView, self.delegate.tableView);
}

- (void)testIngredientData
{
  NSArray *constantIngredientData = @[ @[ @(0) ], @[  @(1) ] ];
  XCTAssertEqualObjects(constantIngredientData, [self.delegate ingredientData]);
}

- (void)testPopulateIngredientCell
{
  self.recipe.preBoilVolumeInGallons = @(9.53);
  self.recipe.postBoilVolumeInGallons = @(8.87);

  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FooBar"];

  [self.delegate populateIngredientCell:cell withIngredientData:@(0)];
  XCTAssertEqualObjects(@"Pre-boil volume", cell.textLabel.text);
  XCTAssertEqualObjects(@"9.53 gal", cell.detailTextLabel.text);

  [self.delegate populateIngredientCell:cell withIngredientData:@(1)];
  XCTAssertEqualObjects(@"Post-boil volume", cell.textLabel.text);
  XCTAssertEqualObjects(@"8.87 gal", cell.detailTextLabel.text);

  XCTAssertThrows([self.delegate populateIngredientCell:cell withIngredientData:@(2)]);
}

- (void)testPopulateDrawerCell
{
  OBMultiPickerTableViewCell *cell = [[OBMultiPickerTableViewCell alloc] initWithFrame:CGRectZero];
  cell.multiPickerView = [[OBMultiPickerView alloc] initWithFrame:CGRectZero];
  
  self.recipe.preBoilVolumeInGallons = @(9.53);
  self.recipe.postBoilVolumeInGallons = @(8.87);

  id mockPickerView = [OCMockObject partialMockForObject:cell.multiPickerView];

  [[[mockPickerView stub] andDo:^(NSInvocation *invocation) {
    // ARC will release this value when this block exits scope, which eventually causes a double free.
    __unsafe_unretained id<OBPickerDelegate> pickerDelegate = nil;
    [invocation getArgument:&pickerDelegate atIndex:2];

    XCTAssertEqualWithAccuracy(9.53, [self.recipe.preBoilVolumeInGallons floatValue], 0.000001);
    [pickerDelegate pickerView:nil didSelectRow:0 inComponent:0];
    XCTAssertEqualWithAccuracy(0, [self.recipe.preBoilVolumeInGallons floatValue], 0.000001);
  }] addPickerDelegate:OCMOCK_ANY withTitle:@"unused"];


  [self.delegate populateDrawerCell:cell withIngredientData:@(0)];
  [mockPickerView verify];
  [mockPickerView stopMocking];

  mockPickerView = [OCMockObject partialMockForObject:cell.multiPickerView];

  [[[mockPickerView stub] andDo:^(NSInvocation *invocation) {
    // ARC will release this value when this block exits scope, which eventually causes a double free.
    __unsafe_unretained id<OBPickerDelegate> pickerDelegate = nil;
    [invocation getArgument:&pickerDelegate atIndex:2];

    XCTAssertEqualWithAccuracy(8.87, [self.recipe.postBoilVolumeInGallons floatValue], 0.000001);
    [pickerDelegate pickerView:nil didSelectRow:0 inComponent:0];
    XCTAssertEqualWithAccuracy(0, [self.recipe.preBoilVolumeInGallons floatValue], 0.000001);
  }] addPickerDelegate:OCMOCK_ANY withTitle:@"unused"];

  [self.delegate populateDrawerCell:cell withIngredientData:@(1)];
  [mockPickerView verify];
  [mockPickerView stopMocking];

  XCTAssertThrows([self.delegate populateDrawerCell:cell withIngredientData:@(2)]);
}

- (void)testTitleForFooterInSection
{
  XCTAssertGreaterThan([self.delegate tableView:self.tableView titleForFooterInSection:0].length, 0);
  XCTAssertGreaterThan([self.delegate tableView:self.tableView titleForFooterInSection:1].length, 0);
  XCTAssertThrows([self.delegate tableView:self.tableView titleForFooterInSection:2]);
}

- (void)testHeightForHeaderInSection
{
  XCTAssertEqual(32, [self.delegate tableView:self.tableView heightForHeaderInSection:0]);
  XCTAssertEqual(32, [self.delegate tableView:self.tableView heightForHeaderInSection:1]);
  XCTAssertEqual(32, [self.delegate tableView:self.tableView heightForHeaderInSection:5000]);
}

- (void)testCanEditRowAtIndexPath
{
  XCTAssertFalse([self.delegate tableView:self.tableView canEditRowAtIndexPath:nil]);
  XCTAssertFalse([self.delegate tableView:self.tableView canEditRowAtIndexPath:self.r0s0]);
}

- (void)testCanMoveRowAtIndexPath
{
  XCTAssertFalse([self.delegate tableView:self.tableView canMoveRowAtIndexPath:nil]);
  XCTAssertFalse([self.delegate tableView:self.tableView canMoveRowAtIndexPath:self.r0s0]);
}

@end
