//
//  OBYeastAdditionViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/18/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBYeastAdditionViewController.h"
#import <OCMock/OCMock.h>
#import "OBIngredientGauge.h"
#import "OBRecipe.h"
#import "OBYeast.h"
#import "OBYeastAddition.h"
#import "OBYeastTableViewCell.h"

@interface OBYeastAdditionViewControllerTest : OBBaseTestCase
@property (nonatomic) OBYeastAdditionViewController *vc;
@end

@implementation OBYeastAdditionViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"yeastAdditionView"];
  self.vc.recipe = self.recipe;
}

- (void)tearDown {
  [super tearDown];
}

- (void)testViewDidLoadSetsUpGauge
{
  [self.vc loadView];

  [self addMalt:@"Maris Otter" quantity:10.0];
  [self addYeast:@"WLP001"];

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];
  [[mockGauge expect] refresh];

  [self.vc viewDidLoad];

  XCTAssertEqual(OBMetricFinalGravity, self.vc.gauge.metricToDisplay);
  XCTAssertEqual(self.recipe, self.vc.gauge.recipe);

  [mockGauge verify];
}

- (void)testViewDidLoad_noYeastSelected_wyeastManufacturer
{
  [self.vc loadView];

  self.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);

  [self.vc viewDidLoad];

  XCTAssertEqual(1, [self.vc.tableView numberOfSections]);
  XCTAssertEqual(49, [self.vc.tableView numberOfRowsInSection:0]);

  XCTAssertEqual(1, [self.vc.segmentedControl selectedSegmentIndex], @"Wyeast segment should be selected (index 1)");

  OBYeastTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"1007", cell.yeastIdentifier.text);
  XCTAssertEqualObjects(@"German Ale", cell.yeastName.text);
  [self validateNoCellsSelected];
}

- (void)testViewDidLoad_noYeastSelected_whiteLabsManufacturer
{
  [self.vc loadView];

  self.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);

  [self.vc viewDidLoad];

  XCTAssertEqual(1, [self.vc.tableView numberOfSections]);
  XCTAssertEqual(42, [self.vc.tableView numberOfRowsInSection:0]);

  XCTAssertEqual(0, [self.vc.segmentedControl selectedSegmentIndex], @"White labs segment should be selected (index 1)");

  OBYeastTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"WLP001", cell.yeastIdentifier.text);
  XCTAssertEqualObjects(@"California Ale", cell.yeastName.text);
  [self validateNoCellsSelected];
}

- (void)validateNoCellsSelected
{
  for (int i = 0; i < [self.vc.tableView numberOfRowsInSection:0]; i++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    OBYeastTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:indexPath];

    if (!cell) {
      continue;
    }

    XCTAssertEqual(UITableViewCellAccessoryNone, cell.accessoryType);
  }
}

- (void)testViewDidLoad_whiteLabsYeastSelected
{
  [self.vc loadView];

  [self addYeast:@"WLP001"];

  self.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);

  [self.vc viewDidLoad];

  XCTAssertEqual(1, [self.vc.tableView numberOfSections]);
  XCTAssertEqual(42, [self.vc.tableView numberOfRowsInSection:0]);

  XCTAssertEqual(0, [self.vc.segmentedControl selectedSegmentIndex], @"White labs segment should be selected (index 1)");

  OBYeastTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"WLP001", cell.yeastIdentifier.text);
  XCTAssertEqualObjects(@"California Ale", cell.yeastName.text);
  XCTAssertEqual(UITableViewCellAccessoryCheckmark, cell.accessoryType);

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqual(UITableViewCellAccessoryNone, cell.accessoryType);
}

- (void)testViewDidLoad_segmentedControlSetup
{
  [self.vc loadView];

  // A manufaturer is selected that is not the manufacturer of the selected yeast
  self.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);

  [self.vc viewDidLoad];

  XCTAssertEqual(2, [self.vc.segmentedControl numberOfSegments]);
  XCTAssertEqualObjects(@"White Labs", [self.vc.segmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@"Wyeast", [self.vc.segmentedControl titleForSegmentAtIndex:1]);
  XCTAssertEqual(1, [self.vc.segmentedControl selectedSegmentIndex]);
}

- (void)testSelectSegment
{
  [self.vc loadView];

  self.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);

  [self.vc viewDidLoad];

  OBYeastTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"WLP001", cell.yeastIdentifier.text);
  XCTAssertEqual(42, [self.vc.tableView numberOfRowsInSection:0]);

  self.vc.segmentedControl.selectedSegmentIndex = 1;
  [self.vc.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"1007", cell.yeastIdentifier.text);
  XCTAssertEqual(49, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertEqual(OBYeastManufacturerWyeast, [self.brewery.selectedYeastManufacturer integerValue]);

  self.vc.segmentedControl.selectedSegmentIndex = 0;
  [self.vc.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"WLP001", cell.yeastIdentifier.text);
  XCTAssertEqual(42, [self.vc.tableView numberOfRowsInSection:0]);
}

- (void)testDidSelectRowAtIndexPath
{
  [self.vc loadView];

  self.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);

  [self.vc viewDidLoad];

  XCTAssertNil(self.recipe.yeast);

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];
  [[mockGauge expect] refresh];

  [self.vc tableView:self.vc.tableView didSelectRowAtIndexPath:self.r0s0];

  XCTAssertEqualObjects(@"WLP001", self.recipe.yeast.yeast.identifier);

  [mockGauge verify];
}

- (void)testCellForRowAtIndexPath
{
  [self.vc loadView];

  self.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);

  [self.vc viewDidLoad];

  OBYeastTableViewCell *cell = (id)[self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0];

  XCTAssertEqualObjects(@"WhiteLabsCell", cell.reuseIdentifier);
  XCTAssertEqualObjects(@"WLP001", cell.yeastIdentifier.text);
  XCTAssertEqualObjects(@"California Ale", cell.yeastName.text);

  self.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);

  cell = (id)[self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"WyeastCell", cell.reuseIdentifier);

  self.brewery.selectedYeastManufacturer = @(2);
  XCTAssertThrows([self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0]);
}

@end
