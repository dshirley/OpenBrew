//
//  OBHopAdditionTableViewDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/5/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBHopAdditionTableViewDelegate.h"
#import "OBBaseTestCase.h"
#import "OBHopAddition.h"
#import <OCMock/OCMock.h>
#import "OBHopAdditionTableViewCell.h"
#import "OBMultiPickerTableViewCell.h"
#import "OBMultiPickerView.h"
#import "OBHopBoilTimePickerDelegate.h"
#import "OBAlphaAcidPickerDelegate.h"
#import "OBHopQuantityPickerDelegate.h"

@interface OBMultiPickerView(Test)

- (UISegmentedControl *)segmentedControl;

- (UIPickerView *)picker;

- (NSArray *)pickerDelegates;

@end


@interface OBHopAdditionTableViewDelegateTest : OBBaseTestCase
@property (nonatomic) OBHopAdditionTableViewDelegate *delegate;
@property (nonatomic) UITableView *tableView;
@end

@implementation OBHopAdditionTableViewDelegateTest

- (void)setUp {
  [super setUp];

  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];

  self.delegate = [[OBHopAdditionTableViewDelegate alloc] initWithRecipe:self.recipe
                                                            andTableView:self.tableView
                                                           andGACategory:@"OBHopAdditionTableViewDelegateTest"];

  XCTAssertEqual(self.recipe, self.delegate.recipe);
  XCTAssertEqual(self.tableView, self.delegate.tableView);
}

- (void)tearDown {
  [super tearDown];
}

- (void)testIngredientData
{
  XCTAssertEqualObjects((@[@[]]), [self.delegate ingredientData]);

  OBHopAddition *hops1 = [self addHops:@"Admiral" quantity:1.0 aaPercent:8.0 boilTime:60];
  XCTAssertEqualObjects((@[@[ hops1 ]]), [self.delegate ingredientData]);

  OBHopAddition *hops2 = [self addHops:@"Cascade" quantity:2.0 aaPercent:7.0 boilTime:60];
  XCTAssertEqualObjects((@[ @[ hops1, hops2 ]]), [self.delegate ingredientData]);

  hops1.displayOrder = @(3);
  XCTAssertEqualObjects((@[ @[ hops2, hops1 ]]), [self.delegate ingredientData]);
}

- (void)testSetHopAdditionMetricToDisplay
{
  id mockTableView = [OCMockObject partialMockForObject:self.tableView];
  [[mockTableView expect] reloadData];

  self.delegate.hopAdditionMetricToDisplay = 50;

  [mockTableView verify];

  XCTAssertEqual(50, self.delegate.hopAdditionMetricToDisplay);

  [mockTableView stopMocking];
}

- (void)testPopulateDrawerCell
{
  OBMultiPickerTableViewCell *cell = [[OBMultiPickerTableViewCell alloc] initWithFrame:CGRectZero];
  OBMultiPickerView *view = [[OBMultiPickerView alloc] initWithFrame:CGRectZero];
  [view awakeFromNib];

  cell.multiPickerView = view;

  OBHopAddition *hops = [self addHops:@"Admiral" quantity:1.0 aaPercent:8.5 boilTime:60];
  OBHopBoilTimePickerDelegate *pickerDelegate = [[OBHopBoilTimePickerDelegate alloc] initWithHopAddition:hops];

  [view addPickerDelegate:pickerDelegate withTitle:@"This should be removed"];

  [self.delegate populateDrawerCell:cell withIngredientData:hops];
  XCTAssertEqual(3, [[view pickerDelegates] count]);
  XCTAssertTrue([[view pickerDelegates][0] isKindOfClass:[OBHopQuantityPickerDelegate class]]);
  XCTAssertTrue([[view pickerDelegates][1] isKindOfClass:[OBAlphaAcidPickerDelegate class]]);
  XCTAssertTrue([[view pickerDelegates][2] isKindOfClass:[OBHopBoilTimePickerDelegate class]]);
  XCTAssertEqual(0, view.segmentedControl.selectedSegmentIndex);
  XCTAssertEqual(self.delegate, view.delegate);
  XCTAssertEqual(NSNotFound, [[view pickerDelegates] indexOfObject:pickerDelegate], @"Old one should have been removed");

  self.delegate.selectedPickerIndex = 2;

  [self.delegate populateDrawerCell:cell withIngredientData:hops];
  XCTAssertEqual(3, [[view pickerDelegates] count]);
  XCTAssertTrue([[view pickerDelegates][0] isKindOfClass:[OBHopQuantityPickerDelegate class]]);
  XCTAssertTrue([[view pickerDelegates][1] isKindOfClass:[OBAlphaAcidPickerDelegate class]]);
  XCTAssertTrue([[view pickerDelegates][2] isKindOfClass:[OBHopBoilTimePickerDelegate class]]);
  XCTAssertEqual(2, view.segmentedControl.selectedSegmentIndex);
  XCTAssertEqual(self.delegate, view.delegate);

  cell.multiPickerView.segmentedControl.selectedSegmentIndex = 1;
  [cell.multiPickerView.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

  XCTAssertEqual(1, self.delegate.selectedPickerIndex);
}

- (void)testPopulateIngredientCell
{
  OBHopAdditionTableViewCell *cell = [[OBHopAdditionTableViewCell alloc] initWithFrame:CGRectZero];
  UILabel *hopVariety = [[UILabel alloc] initWithFrame:CGRectZero];
  UILabel *alphaAcid = [[UILabel alloc] initWithFrame:CGRectZero];
  UILabel *primaryMetric = [[UILabel alloc] initWithFrame:CGRectZero];
  UILabel *boilTime = [[UILabel alloc] initWithFrame:CGRectZero];
  UILabel *boilUnits = [[UILabel alloc] initWithFrame:CGRectZero];

  cell.hopVariety = hopVariety;
  cell.alphaAcid = alphaAcid;
  cell.primaryMetric = primaryMetric;
  cell.boilTime = boilTime;
  cell.boilUnits = boilUnits;

  OBHopAddition *hops = [self addHops:@"Admiral" quantity:1.0 aaPercent:8.5 boilTime:60];

  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"Admiral", hopVariety.text);
  XCTAssertEqualObjects(@"8.5%", alphaAcid.text);
  XCTAssertEqualObjects(@"1.0 oz", primaryMetric.text);
  XCTAssertEqualObjects(@"60", boilTime.text);
  XCTAssertEqualObjects(@"min", boilUnits.text);

  self.delegate.hopAdditionMetricToDisplay = OBHopAdditionMetricIbu;
  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"Admiral", hopVariety.text);
  XCTAssertEqualObjects(@"8.5%", alphaAcid.text);
  XCTAssertEqualObjects(@"38 IBUs", primaryMetric.text);
  XCTAssertEqualObjects(@"60", boilTime.text);
  XCTAssertEqualObjects(@"min", boilUnits.text);

  self.delegate.hopAdditionMetricToDisplay = 2;
  XCTAssertThrows([self.delegate populateIngredientCell:cell withIngredientData:hops]);
}


@end
