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
#import "OBPickerDelegate.h"

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

- (void)testSetHopQuantityUnits
{
  id mockTableView = [OCMockObject partialMockForObject:self.tableView];
  [[mockTableView expect] reloadData];

  self.delegate.hopQuantityUnits = 50;

  [mockTableView verify];

  XCTAssertEqual(50, self.delegate.hopQuantityUnits);

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

  XCTAssertEqualObjects([[view pickerDelegates][0] key], @"quantityInOunces");
  XCTAssertEqual([[view pickerDelegates][0] target], hops);
  XCTAssertEqualObjects([[view pickerDelegates][1] key], @"alphaAcidPercent");
  XCTAssertEqual([[view pickerDelegates][1] target], hops);
  XCTAssertTrue([[view pickerDelegates][2] isKindOfClass:[OBHopBoilTimePickerDelegate class]]);
  XCTAssertEqual(0, view.segmentedControl.selectedSegmentIndex);
  XCTAssertEqual(self.delegate, view.delegate);
  XCTAssertEqual(NSNotFound, [[view pickerDelegates] indexOfObject:pickerDelegate], @"Old one should have been removed");

  self.delegate.selectedPickerIndex = 2;

  [self.delegate populateDrawerCell:cell withIngredientData:hops];
  XCTAssertEqual(3, [[view pickerDelegates] count]);
  XCTAssertEqualObjects([[view pickerDelegates][0] key], @"quantityInOunces");
  XCTAssertEqual([[view pickerDelegates][0] target], hops);
  XCTAssertEqualObjects([[view pickerDelegates][1] key], @"alphaAcidPercent");
  XCTAssertEqual([[view pickerDelegates][1] target], hops);
  XCTAssertTrue([[view pickerDelegates][2] isKindOfClass:[OBHopBoilTimePickerDelegate class]]);
  XCTAssertEqual(2, view.segmentedControl.selectedSegmentIndex);
  XCTAssertEqual(self.delegate, view.delegate);

  cell.multiPickerView.segmentedControl.selectedSegmentIndex = 1;
  [cell.multiPickerView.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

  XCTAssertEqual(1, self.delegate.selectedPickerIndex);

  self.delegate.hopQuantityUnits = OBHopQuantityUnitsMetric;
  [self.delegate populateDrawerCell:cell withIngredientData:hops];
  XCTAssertEqual(3, [[view pickerDelegates] count]);
  XCTAssertEqualObjects([[view pickerDelegates][0] key], @"quantityInGrams");
  XCTAssertEqual([[view pickerDelegates][0] target], hops);
  XCTAssertEqualObjects([[view pickerDelegates][1] key], @"alphaAcidPercent");
  XCTAssertEqual([[view pickerDelegates][1] target], hops);
  XCTAssertTrue([[view pickerDelegates][2] isKindOfClass:[OBHopBoilTimePickerDelegate class]]);
}

- (void)testPopulateDrawerCell_invalidHopQuantityUnits
{
  OBMultiPickerTableViewCell *cell = [[OBMultiPickerTableViewCell alloc] initWithFrame:CGRectZero];
  OBHopAddition *hops = [self addHops:@"Admiral" quantity:1.0 aaPercent:8.5 boilTime:60];
  self.delegate.hopQuantityUnits = 50;
  XCTAssertThrows([self.delegate populateDrawerCell:cell withIngredientData:hops]);
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
  self.settings.ibuFormula = @(OBIbuFormulaTinseth);
  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"Admiral", hopVariety.text);
  XCTAssertEqualObjects(@"8.5%", alphaAcid.text);
  XCTAssertEqualObjects(@"38 IBUs", primaryMetric.text);
  XCTAssertEqualObjects(@"60", boilTime.text);
  XCTAssertEqualObjects(@"min", boilUnits.text);

  self.settings.ibuFormula = @(OBIbuFormulaRager);
  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"33 IBUs", primaryMetric.text);

  self.delegate.hopAdditionMetricToDisplay = 2;
  XCTAssertThrows([self.delegate populateIngredientCell:cell withIngredientData:hops]);
}

- (void)testPopulateIngredientCell_nonStandardBoilTime
{
  OBHopAdditionTableViewCell *cell = [[OBHopAdditionTableViewCell alloc] initWithFrame:CGRectZero];
  UILabel *boilTime = [[UILabel alloc] initWithFrame:CGRectZero];
  UILabel *boilUnits = [[UILabel alloc] initWithFrame:CGRectZero];

  cell.boilTime = boilTime;
  cell.boilUnits = boilUnits;

  OBHopAddition *hops = [self addHops:@"Admiral" quantity:1.0 aaPercent:8.5 boilTime:300];
  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"300", boilTime.text);
  XCTAssertEqualObjects(@"min", boilUnits.text);

  hops.boilTimeInMinutes = @(1.5);
  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"1", boilTime.text);
  XCTAssertEqualObjects(@"min", boilUnits.text);
}

- (void)testPopulateIngredientCell_nonStandardAlphaAcid
{
  OBHopAdditionTableViewCell *cell = [[OBHopAdditionTableViewCell alloc] initWithFrame:CGRectZero];
  UILabel *alphaAcid = [[UILabel alloc] initWithFrame:CGRectZero];

  cell.alphaAcid = alphaAcid;

  OBHopAddition *hops = [self addHops:@"Admiral" quantity:1.0 aaPercent:8.53103 boilTime:300];
  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"8.5%", alphaAcid.text);

  hops.alphaAcidPercent = @(99.99);
  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"100.0%", alphaAcid.text);
}

- (void)testPopulateIngredientCell_metricHopQuantities
{
  OBHopAdditionTableViewCell *cell = [[OBHopAdditionTableViewCell alloc] initWithFrame:CGRectZero];
  UILabel *quantity = [[UILabel alloc] initWithFrame:CGRectZero];

  cell.primaryMetric = quantity;

  OBHopAddition *hops = [self addHops:@"Admiral" quantity:1.0 aaPercent:8.53103 boilTime:300];
  hops.quantityInGrams = @(53);

  self.delegate.hopQuantityUnits = OBHopQuantityUnitsMetric;
  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"53 g", quantity.text);

  self.delegate.hopQuantityUnits = OBHopQuantityUnitsMetric;
  hops.quantityInGrams = @(99.99);
  [self.delegate populateIngredientCell:cell withIngredientData:hops];
  XCTAssertEqualObjects(@"100 g", quantity.text);
}

- (void)testPopulateIngredientCell_invalidHopQuantity
{
  OBHopAdditionTableViewCell *cell = [[OBHopAdditionTableViewCell alloc] initWithFrame:CGRectZero];
  OBHopAddition *hops = [self addHops:@"Admiral" quantity:1.0 aaPercent:8.53103 boilTime:300];

  self.delegate.hopQuantityUnits = 50;
  XCTAssertThrows([self.delegate populateIngredientCell:cell withIngredientData:hops]);
}

@end
