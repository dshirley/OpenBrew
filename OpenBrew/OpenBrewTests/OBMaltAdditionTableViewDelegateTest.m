//
//  OBMaltAdditionTableViewDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/7/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBMaltAdditionTableViewDelegate.h"
#import "OBMaltAdditionTableViewCell.h"
#import "OBMultiPickerTableViewCell.h"

@interface OBMaltAdditionTableViewDelegateTest : OBBaseTestCase
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) OBMaltAdditionTableViewDelegate *delegate;
@end

@implementation OBMaltAdditionTableViewDelegateTest

- (void)setUp {
  [super setUp];

  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 240, 320)];
  self.delegate = [[OBMaltAdditionTableViewDelegate alloc] initWithRecipe:self.recipe
                                                             andTableView:self.tableView
                                                            andGACategory:@"testing"];

  self.tableView.dataSource = self.delegate;
  self.tableView.delegate = self.delegate;

  [self.tableView registerClass:[OBMaltAdditionTableViewCell class] forCellReuseIdentifier:@"IngredientAddition"];
  [self.tableView registerClass:[OBMultiPickerTableViewCell class] forCellReuseIdentifier:@"DrawerCell"];

  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 0);
}

- (void)tearDown {
  [super tearDown];
}

- (void)testNumberOfRowsInSection
{
  [self addMalt:@"Pilsner Malt" quantity:10.0];
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 1);

  [self addMalt:@"Acid Malt" quantity:10.0];
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 2);

  XCTAssertThrows([self.delegate tableView:self.tableView numberOfRowsInSection:1], @"Index out of bounds error");

  // TODO: test opening the drawer and closing the drawer
}

- (void)testNumberOfSectionsInTableView
{
  XCTAssertEqual([self.delegate numberOfSectionsInTableView:self.tableView], 1);
  [self addMalt:@"Pilsner Malt" quantity:10.0];

  XCTAssertEqual([self.delegate numberOfSectionsInTableView:self.tableView], 1, @"Still no change");
}

// The testCanEditRowAtIndexPath and testCanMoveRowAtIndexPath require the exact same logic.
// Rather than copy/paste the entire test, the code should be factored out into a single
// helper test method that takes in a block that either calls either canEditRow or canMoveRow.
typedef BOOL(^CanChangeRowAtIndexPath)(NSIndexPath *indexPath);

- (void)testCanEditRowAtIndexPath
{
  [self doTestCanChangeRowAtIndexPathWithBlock:^BOOL(NSIndexPath *indexPath) {
    return [self.delegate tableView:self.tableView canEditRowAtIndexPath:indexPath];
  }];
}

- (void)testCanMoveRowAtIndexPath
{
  [self doTestCanChangeRowAtIndexPathWithBlock:^BOOL(NSIndexPath *indexPath) {
    return [self.delegate tableView:self.tableView canMoveRowAtIndexPath:indexPath];
  }];
}

- (void)doTestCanChangeRowAtIndexPathWithBlock:(CanChangeRowAtIndexPath)canChange
{
  NSIndexPath *r0s0 = [NSIndexPath indexPathForRow:0 inSection:0];
  NSIndexPath *r1s0 = [NSIndexPath indexPathForRow:1 inSection:0];
  NSIndexPath *r2s0 = [NSIndexPath indexPathForRow:2 inSection:0];
  NSIndexPath *r9s9 = [NSIndexPath indexPathForRow:9 inSection:9];

  // Use the default behavior "all rows are assumed editable" unless told otherwise.
  // Even if it is out of range.  It is editable.
  XCTAssertTrue(canChange(r0s0));
  XCTAssertTrue(canChange(r9s9));

  [self addMalt:@"Crystal 10" quantity:0.5];
  XCTAssertTrue(canChange(r0s0));

  [self addMalt:@"Crystal 20" quantity:0.5];
  XCTAssertTrue(canChange(r1s0));

  // Test opening the drawer.  The drawer itself should not be editable, but other cells should be.
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:r0s0];
  XCTAssertTrue(canChange(r0s0));
  XCTAssertFalse(canChange(r1s0), @"Drawer cells should not be editable");
  XCTAssertTrue(canChange(r2s0));

  // Nothing should change when selecting the drawer cell
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:r1s0];
  XCTAssertTrue(canChange(r0s0));
  XCTAssertFalse(canChange(r1s0), @"Drawer cells should not be editable");
  XCTAssertTrue(canChange(r2s0));

  // Selecting the last table view cell should rotate where the drawer is and also which cells are editable
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:r2s0];
  XCTAssertTrue(canChange(r0s0));
  XCTAssertTrue(canChange(r1s0));
  XCTAssertFalse(canChange(r2s0), @"Drawer cells should not be editable");

  // Close the drawer. All cells should be editable again
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:r1s0];
  XCTAssertTrue(canChange(r0s0));
  XCTAssertTrue(canChange(r1s0));
  XCTAssertTrue(canChange(r2s0), @"Cells out of range should be editable");
}

// Methods that need testing:

//- (UITableViewCell *)tableView:(UITableView *)tableView
//         cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//forRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
//      toIndexPath:(NSIndexPath *)destinationIndexPath;
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (NSArray *)ingredientData;
//
//- (void)populateIngredientCell:(UITableViewCell *)cell
//            withIngredientData:(id)ingredientData;
//
//- (void)populateDrawerCell:(UITableViewCell *)cell
//        withIngredientData:(id)ingredientData;

@end
