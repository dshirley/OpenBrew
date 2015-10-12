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
#import "OBRecipe.h"
#import "OBYeast.h"
#import "OBYeastAddition.h"
#import "OBYeastTableViewCell.h"
#import "OBGaugePageViewController.h"
#import "OBKvoUtils.h"

@interface OBYeastAdditionViewControllerTest : OBBaseTestCase
@property (nonatomic) OBYeastAdditionViewController *vc;
@end

@implementation OBYeastAdditionViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"yeastAdditionView"];
  self.vc.recipe = self.recipe;
  self.vc.settings = self.settings;
}

- (void)tearDown {
  [super tearDown];
}

- (void)loadViewController
{
  (void)self.vc.view;
}

- (void)testViewDidLoadSetsUpGauge
{
  [self loadViewController];

  [self addMalt:@"Maris Otter" quantity:10.0];
  [self addYeast:@"WLP001"];

  XCTAssertNotNil(self.vc.pageViewControllerDataSource);
  XCTAssertNotNil(self.vc.pageViewControllerDataSource.viewControllers);
  XCTAssertEqual(2, self.vc.pageViewControllerDataSource.viewControllers.count);

  XCTAssertEqual(self.recipe, [self.vc.pageViewControllerDataSource.viewControllers[0] target]);
  XCTAssertEqualObjects(KVO_KEY(alcoholByVolume), [self.vc.pageViewControllerDataSource.viewControllers[0] key]);

  XCTAssertEqual(self.recipe, [self.vc.pageViewControllerDataSource.viewControllers[1] target]);
  XCTAssertEqualObjects(KVO_KEY(finalGravity), [self.vc.pageViewControllerDataSource.viewControllers[1] key]);

  XCTAssertEqual(1, self.vc.childViewControllers.count);

  OBGaugePageViewController *pageViewController = (id)self.vc.childViewControllers[0];
  XCTAssertEqual(OBGaugePageViewController.class, pageViewController.class);
  XCTAssertEqual(self.vc.pageViewControllerDataSource, pageViewController.dataSource);
}

- (void)testViewDidLoad_noYeastSelected_wyeastManufacturer
{
  [self loadViewController];

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);

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
  [self loadViewController];

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);

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
  [self loadViewController];

  [self addYeast:@"WLP001"];

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);

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
  [self loadViewController];

  // A manufaturer is selected that is not the manufacturer of the selected yeast
  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);

  [self.vc viewDidLoad];

  XCTAssertEqual(2, [self.vc.segmentedControl numberOfSegments]);
  XCTAssertEqualObjects(@"White Labs", [self.vc.segmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@"Wyeast", [self.vc.segmentedControl titleForSegmentAtIndex:1]);
  XCTAssertEqual(1, [self.vc.segmentedControl selectedSegmentIndex]);
}

- (void)testSelectSegment
{
  [self loadViewController];

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);

  [self.vc viewDidLoad];

  OBYeastTableViewCell *cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"WLP001", cell.yeastIdentifier.text);
  XCTAssertEqual(42, [self.vc.tableView numberOfRowsInSection:0]);

  self.vc.segmentedControl.selectedSegmentIndex = 1;
  [self.vc.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"1007", cell.yeastIdentifier.text);
  XCTAssertEqual(49, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertEqual(OBYeastManufacturerWyeast, [self.settings.selectedYeastManufacturer integerValue]);

  self.vc.segmentedControl.selectedSegmentIndex = 0;
  [self.vc.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

  cell = (id)[self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"WLP001", cell.yeastIdentifier.text);
  XCTAssertEqual(42, [self.vc.tableView numberOfRowsInSection:0]);
}

- (void)testDidSelectRowAtIndexPath
{
  [self loadViewController];

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);

  [self.vc viewDidLoad];

  XCTAssertNil(self.recipe.yeast);

  [self.vc tableView:self.vc.tableView didSelectRowAtIndexPath:self.r0s0];

  XCTAssertEqualObjects(@"WLP001", self.recipe.yeast.identifier);
}

- (void)testCellForRowAtIndexPath
{
  [self loadViewController];

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);

  [self.vc viewDidLoad];

  OBYeastTableViewCell *cell = (id)[self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0];

  XCTAssertEqualObjects(@"WhiteLabsCell", cell.reuseIdentifier);
  XCTAssertEqualObjects(@"WLP001", cell.yeastIdentifier.text);
  XCTAssertEqualObjects(@"California Ale", cell.yeastName.text);

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);

  cell = (id)[self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"WyeastCell", cell.reuseIdentifier);

  self.settings.selectedYeastManufacturer = @(2);
  XCTAssertThrows([self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0]);
}

#pragma mark OBSegmentedControlDelegate tests

- (void)testSegmentTitles
{
  (void)self.vc.view;

  XCTAssertEqualObjects((@[ @"White Labs", @"Wyeast" ]), [self.vc.segmentedControl.delegate segmentTitlesForSegmentedControl:nil]);
}

- (void)testSegmentSelected
{
  (void)self.vc.view;

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);

  [self.vc.segmentedControl.delegate segmentedControl:nil segmentSelected:0];
  XCTAssertEqualObjects(@(OBYeastManufacturerWhiteLabs), self.settings.selectedYeastManufacturer);

  [self.vc.segmentedControl.delegate segmentedControl:nil segmentSelected:1];
  XCTAssertEqualObjects(@(OBYeastManufacturerWyeast), self.settings.selectedYeastManufacturer);
}

- (void)testInitiallySelectedSegment_noYeastSelected
{
  (void)self.vc.view;

  self.recipe.yeast = nil;

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);
  XCTAssertEqual(1, [self.vc.segmentedControl.delegate initiallySelectedSegmentForSegmentedControl:nil]);

  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);
  XCTAssertEqual(0, [self.vc.segmentedControl.delegate initiallySelectedSegmentForSegmentedControl:nil]);
}

// When a yeast has been added to the recipe, the selectedYeastManufacturere should be ignored
- (void)testInitiallySelectedSegment_yeastSelected
{
  (void)self.vc.view;
  
  [self addYeast:@"WLP001"];
  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);
  XCTAssertEqual(0, [self.vc.segmentedControl.delegate initiallySelectedSegmentForSegmentedControl:nil]);

  [self addYeast:@"1007"];
  self.settings.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);
  XCTAssertEqual(1, [self.vc.segmentedControl.delegate initiallySelectedSegmentForSegmentedControl:nil]);
}



@end
