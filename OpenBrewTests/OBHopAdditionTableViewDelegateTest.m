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

- (void)testIngredientData_nilHopAdditions
{
  id mock = [OCMockObject partialMockForObject:self.recipe];
  [[[mock stub] andReturn:nil] hopAdditionsSorted];

  XCTAssertEqualObjects((@[@[]]), [self.delegate ingredientData]);

  [mock verify];
  [mock stopMocking];
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

//
//@property (nonatomic, assign) OBHopAdditionMetric hopAdditionMetricToDisplay;

//@property (nonatomic, assign) NSInteger selectedPickerIndex;
//
//- (void)populateIngredientCell:(UITableViewCell *)cell
//            withIngredientData:(id)ingredientData;
//
//- (void)populateDrawerCell:(UITableViewCell *)cell
//        withIngredientData:(id)ingredientData;

@end
