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
#import "OBMaltAddition.h"

@interface OBMaltAdditionTableViewDelegateTest : OBBaseTestCase
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) OBMaltAdditionTableViewDelegate *delegate;
@property (nonatomic, strong) NSIndexPath *r0s0;
@property (nonatomic, strong) NSIndexPath *r1s0;
@property (nonatomic, strong) NSIndexPath *r2s0;
@property (nonatomic, strong) NSIndexPath *r3s0;
@end

@implementation OBMaltAdditionTableViewDelegateTest

- (void)setUp {
  [super setUp];

  self.r0s0 = [NSIndexPath indexPathForRow:0 inSection:0];
  self.r1s0 = [NSIndexPath indexPathForRow:1 inSection:0];
  self.r2s0 = [NSIndexPath indexPathForRow:2 inSection:0];
  self.r3s0 = [NSIndexPath indexPathForRow:3 inSection:0];

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

  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r0s0];
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 3);

  // Selecting the drawer shouldn't change the number of rows
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r1s0];
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 3);

  // Reopen the drawer in a different location. Number of rows should be the same.
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r2s0];
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 3);

  // Close the drawer
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r1s0];
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 2);
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
  NSIndexPath *r9s9 = [NSIndexPath indexPathForRow:9 inSection:9];

  // Use the default behavior "all rows are assumed editable" unless told otherwise.
  // Even if it is out of range.  It is editable.
  XCTAssertTrue(canChange(self.r0s0));
  XCTAssertTrue(canChange(r9s9));

  [self addMalt:@"Crystal 10" quantity:0.5];
  XCTAssertTrue(canChange(self.r0s0));

  [self addMalt:@"Crystal 20" quantity:0.5];
  XCTAssertTrue(canChange(self.r1s0));

  // Test opening the drawer.  The drawer itself should not be editable, but other cells should be.
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r0s0];
  XCTAssertTrue(canChange(self.r0s0));
  XCTAssertFalse(canChange(self.r1s0), @"Drawer cells should not be editable");
  XCTAssertTrue(canChange(self.r2s0));

  // Nothing should change when selecting the drawer cell
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r1s0];
  XCTAssertTrue(canChange(self.r0s0));
  XCTAssertFalse(canChange(self.r1s0), @"Drawer cells should not be editable");
  XCTAssertTrue(canChange(self.r2s0));

  // Selecting the last table view cell should rotate where the drawer is and also which cells are editable
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r2s0];
  XCTAssertTrue(canChange(self.r0s0));
  XCTAssertTrue(canChange(self.r1s0));
  XCTAssertFalse(canChange(self.r2s0), @"Drawer cells should not be editable");

  // Close the drawer. All cells should be editable again
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r1s0];
  XCTAssertTrue(canChange(self.r0s0));
  XCTAssertTrue(canChange(self.r1s0));
  XCTAssertTrue(canChange(self.r2s0), @"Cells out of range should be editable");
}

- (void)testCommitEditingStyle_DeleteThreeRowsFromBottomUp
{
  OBMaltAddition *malt1 = [self addMalt:@"Crystal 30" quantity:0.5];
  OBMaltAddition *malt2 = [self addMalt:@"Crystal 60" quantity:0.5];
  OBMaltAddition *malt3 = [self addMalt:@"Crystal 120" quantity:0.5];

  XCTAssertEqual(self.recipe.maltAdditions.count, 3);
  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 3);

  [self.delegate tableView:self.tableView
        commitEditingStyle:UITableViewCellEditingStyleDelete
         forRowAtIndexPath:self.r2s0];

  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 2);
  XCTAssertEqual(self.recipe.maltAdditions.count, 2);
  XCTAssertNil(malt3.recipe);
  XCTAssertEqual(malt2.recipe, self.recipe);
  XCTAssertEqual(malt1.recipe, self.recipe);
  XCTAssertEqual([malt2.displayOrder integerValue], 1);
  XCTAssertEqual([malt1.displayOrder integerValue], 0);

  [self.delegate tableView:self.tableView
        commitEditingStyle:UITableViewCellEditingStyleDelete
         forRowAtIndexPath:self.r1s0];

  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 1);
  XCTAssertEqual(self.recipe.maltAdditions.count, 1);
  XCTAssertNil(malt3.recipe);
  XCTAssertNil(malt2.recipe);
  XCTAssertEqual(malt1.recipe, self.recipe);
  XCTAssertEqual([malt1.displayOrder integerValue], 0);

  [self.delegate tableView:self.tableView
        commitEditingStyle:UITableViewCellEditingStyleDelete
         forRowAtIndexPath:self.r0s0];

  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 0);
  XCTAssertEqual(self.recipe.maltAdditions.count, 0);
  XCTAssertNil(malt3.recipe);
  XCTAssertNil(malt2.recipe);
  XCTAssertNil(malt1.recipe);
}

- (void)testCommitEditingStyle_DeleteThreeRowsFromTopDown
{
  OBMaltAddition *malt1 = [self addMalt:@"Crystal 30" quantity:0.5];
  OBMaltAddition *malt2 = [self addMalt:@"Crystal 60" quantity:0.5];
  OBMaltAddition *malt3 = [self addMalt:@"Crystal 120" quantity:0.5];

  XCTAssertEqual(self.recipe.maltAdditions.count, 3);
  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 3);

  [self.delegate tableView:self.tableView
        commitEditingStyle:UITableViewCellEditingStyleDelete
         forRowAtIndexPath:self.r0s0];

  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 2);
  XCTAssertEqual(self.recipe.maltAdditions.count, 2);
  XCTAssertNil(malt1.recipe);
  XCTAssertEqual(malt2.recipe, self.recipe);
  XCTAssertEqual(malt3.recipe, self.recipe);
  XCTAssertEqual([malt2.displayOrder integerValue], 0);
  XCTAssertEqual([malt3.displayOrder integerValue], 1);

  [self.delegate tableView:self.tableView
        commitEditingStyle:UITableViewCellEditingStyleDelete
         forRowAtIndexPath:self.r0s0];

  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 1);
  XCTAssertEqual(self.recipe.maltAdditions.count, 1);
  XCTAssertNil(malt1.recipe);
  XCTAssertNil(malt2.recipe);
  XCTAssertEqual(malt3.recipe, self.recipe);
  XCTAssertEqual([malt3.displayOrder integerValue], 0);

  [self.delegate tableView:self.tableView
        commitEditingStyle:UITableViewCellEditingStyleDelete
         forRowAtIndexPath:self.r0s0];

  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 0);
  XCTAssertEqual(self.recipe.maltAdditions.count, 0);
  XCTAssertNil(malt3.recipe);
  XCTAssertNil(malt2.recipe);
  XCTAssertNil(malt1.recipe);
}

- (void)testCommitEditingStyle_DeleteRowAboveRowWithDrawer
{
  OBMaltAddition *malt1 = [self addMalt:@"Crystal 30" quantity:0.5];
  OBMaltAddition *malt2 = [self addMalt:@"Crystal 60" quantity:0.5];
  OBMaltAddition *malt3 = [self addMalt:@"Crystal 120" quantity:0.5];

  XCTAssertEqual(self.recipe.maltAdditions.count, 3);
  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 3);

  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r1s0];

  [self.delegate tableView:self.tableView
        commitEditingStyle:UITableViewCellEditingStyleDelete
         forRowAtIndexPath:self.r0s0];


  XCTAssertEqual(2, self.recipe.maltAdditions.count);
  XCTAssertNil(malt1.recipe);
  XCTAssertEqualObjects(malt2.displayOrder, @(0));
  XCTAssertEqualObjects(malt3.displayOrder, @(1));

  XCTAssertEqualObjects([self.delegate drawerIndexPath], self.r1s0);
}

- (void)testCommitEditingStyle_DeleteRowWithDrawerOpen
{
  OBMaltAddition *malt1 = [self addMalt:@"Crystal 30" quantity:0.5];
  OBMaltAddition *malt2 = [self addMalt:@"Crystal 60" quantity:0.5];
  OBMaltAddition *malt3 = [self addMalt:@"Crystal 120" quantity:0.5];

  XCTAssertEqual(self.recipe.maltAdditions.count, 3);
  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 3);

  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r1s0];

  [self.delegate tableView:self.tableView
        commitEditingStyle:UITableViewCellEditingStyleDelete
         forRowAtIndexPath:self.r1s0];

  XCTAssertEqual(2, self.recipe.maltAdditions.count);
  XCTAssertEqualObjects(malt1.displayOrder, @(0));
  XCTAssertNil(malt2.recipe);
  XCTAssertEqualObjects(malt3.displayOrder, @(1));

  XCTAssertNil([self.delegate drawerIndexPath]);
}

- (void)testCommitEditingStyle_DeleteRowBelowDrawer
{
  OBMaltAddition *malt1 = [self addMalt:@"Crystal 30" quantity:0.5];
  OBMaltAddition *malt2 = [self addMalt:@"Crystal 60" quantity:0.5];
  OBMaltAddition *malt3 = [self addMalt:@"Crystal 120" quantity:0.5];

  XCTAssertEqual(self.recipe.maltAdditions.count, 3);
  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 3);

  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r1s0];

  [self.delegate tableView:self.tableView
        commitEditingStyle:UITableViewCellEditingStyleDelete
         forRowAtIndexPath:self.r3s0];

  XCTAssertEqual(2, self.recipe.maltAdditions.count);

  XCTAssertEqualObjects(malt1.displayOrder, @(0));
  XCTAssertEqualObjects(malt2.displayOrder, @(1));
  XCTAssertNil(malt3.recipe);

  XCTAssertEqualObjects([self.delegate drawerIndexPath], self.r2s0);
}

- (void)testDidSelectRowAtIndexPath_SingleCell
{
  [self addMalt:@"Two-Row" quantity:0.5];

  // Open the drawer
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r0s0];

  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 2);
  XCTAssertEqual([self.delegate numberOfSectionsInTableView:self.tableView], 1);
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 2);

  // Select the drawer.  Nothing should happen
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r1s0];

  XCTAssertEqualObjects([self.delegate drawerIndexPath], self.r1s0);
  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 2);
  XCTAssertEqual([self.delegate numberOfSectionsInTableView:self.tableView], 1);
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 2);

  // Close the drawer
  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r0s0];

  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 1);
  XCTAssertEqual([self.delegate numberOfSectionsInTableView:self.tableView], 1);
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 1);
}

- (void)testDidSelectRowAtIndexPath_AddCellsWhileDrawersOpen
{
  [self addMalt:@"Victory" quantity:0.5];

  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r0s0];

  [self addMalt:@"Rye LME" quantity:1.5];

  XCTAssertEqualObjects([self.delegate drawerIndexPath], self.r1s0);
  XCTAssertEqual([self.tableView numberOfRowsInSection:0], 2);
  XCTAssertEqual([self.delegate numberOfSectionsInTableView:self.tableView], 1);
  XCTAssertEqual([self.delegate tableView:self.tableView numberOfRowsInSection:0], 3);
}

- (void)testCellForRowAtIndexPath
{
  OBMaltAdditionTableViewCell *maltCell = nil;
  OBMultiPickerTableViewCell *drawerCell = nil;

  [self addMalt:@"Victory" quantity:0.5];

  maltCell = (OBMaltAdditionTableViewCell *)[self.delegate tableView:self.tableView
                                               cellForRowAtIndexPath:self.r0s0];

  XCTAssertEqual(maltCell.class, OBMaltAdditionTableViewCell.class);

  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r0s0];

  drawerCell = (OBMultiPickerTableViewCell *)[self.delegate tableView:self.tableView
                                                cellForRowAtIndexPath:self.r1s0];

  XCTAssertEqual(drawerCell.class, OBMultiPickerTableViewCell.class);

  [self addMalt:@"Rye LME" quantity:1.25];

  maltCell = (OBMaltAdditionTableViewCell *)[self.delegate tableView:self.tableView
                                               cellForRowAtIndexPath:self.r2s0];

  XCTAssertEqual(maltCell.class, OBMaltAdditionTableViewCell.class);
}

- (void)testIngredientData
{
  NSArray *data = nil;
  OBMaltAddition *malt1 = [self addMalt:@"Crystal 30" quantity:0.5];

  XCTAssertEqualObjects([self.delegate ingredientData], @[ @[ malt1 ]]);

  OBMaltAddition *malt2 = [self addMalt:@"Crystal 60" quantity:0.5];
  XCTAssertEqualObjects([self.delegate ingredientData], (@[ @[ malt1, malt2 ]]));

  OBMaltAddition *malt3 = [self addMalt:@"Crystal 120" quantity:0.5];
  XCTAssertEqualObjects([self.delegate ingredientData], (@[ @[ malt1, malt2, malt3 ]]));

  // Rearrange the order
  malt1.displayOrder = @(3);

  data = [self.delegate ingredientData];
  XCTAssertEqualObjects([self.delegate ingredientData], (@[ @[ malt2, malt3, malt1 ]]));
}

- (void)testPopulateIngredientCell
{
  OBMaltAdditionTableViewCell *cell = [[OBMaltAdditionTableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
  UILabel *maltVariety = [[UILabel alloc] initWithFrame:CGRectZero];
  UILabel *primaryMetric = [[UILabel alloc] initWithFrame:CGRectZero];
  UILabel *color = [[UILabel alloc] initWithFrame:CGRectZero];

  cell.maltVariety = maltVariety;
  cell.primaryMetric = primaryMetric;
  cell.color = color;

  OBMaltAddition *malt = [self addMalt:@"Crystal 120" quantity:1.25];

  [self.delegate populateIngredientCell:cell withIngredientData:malt];

  XCTAssertEqualObjects(cell.maltVariety.text, @"Crystal 120");
  XCTAssertEqualObjects(cell.primaryMetric.text, @"1lb 4oz");
  XCTAssertEqualObjects(cell.color.text, @"120 Lovibond");

  // Change the primary metric to % of gravity
  self.delegate.maltAdditionMetricToDisplay = OBMaltAdditionMetricPercentOfGravity;

  [self.delegate populateIngredientCell:cell withIngredientData:malt];

  XCTAssertEqualObjects(cell.maltVariety.text, @"Crystal 120");
  XCTAssertEqualObjects(cell.primaryMetric.text, @"100%");
  XCTAssertEqualObjects(cell.color.text, @"120 Lovibond");
}

- (void)testMoveRowToSameSpot
{
  OBMaltAddition *malt1 = [self addMalt:@"Crystal 30" quantity:0.5];
  OBMaltAddition *malt2 = [self addMalt:@"Crystal 60" quantity:0.5];
  OBMaltAddition *malt3 = [self addMalt:@"Crystal 120" quantity:0.5];

  [self.delegate tableView:self.tableView moveRowAtIndexPath:self.r0s0 toIndexPath:self.r0s0];

  XCTAssertEqualObjects(malt1.displayOrder, @(0));
  XCTAssertEqualObjects(malt2.displayOrder, @(1));
  XCTAssertEqualObjects(malt3.displayOrder, @(2));
}

- (void)testMoveRowToSameSpotWithDrawerOpen
{
  [self addMalt:@"Crystal 30" quantity:0.5];
  [self addMalt:@"Crystal 60" quantity:0.5];
  [self addMalt:@"Crystal 120" quantity:0.5];

  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r2s0];

  XCTAssertThrows([self.delegate tableView:self.tableView moveRowAtIndexPath:self.r0s0 toIndexPath:self.r1s0]);
}

- (void)testMoveRow
{
  OBMaltAddition *malt1 = [self addMalt:@"Crystal 30" quantity:0.5];
  OBMaltAddition *malt2 = [self addMalt:@"Crystal 60" quantity:0.5];
  OBMaltAddition *malt3 = [self addMalt:@"Crystal 120" quantity:0.5];

  [self.delegate tableView:self.tableView moveRowAtIndexPath:self.r0s0 toIndexPath:self.r1s0];

  XCTAssertEqualObjects(malt2.displayOrder, @(0));
  XCTAssertEqualObjects(malt1.displayOrder, @(1));
  XCTAssertEqualObjects(malt3.displayOrder, @(2));

  [self.delegate tableView:self.tableView moveRowAtIndexPath:self.r2s0 toIndexPath:self.r0s0];

  XCTAssertEqualObjects(malt3.displayOrder, @(0));
  XCTAssertEqualObjects(malt2.displayOrder, @(1));
  XCTAssertEqualObjects(malt1.displayOrder, @(2));
}

- (void)testMoveRowWithDrawerOpen
{
  [self addMalt:@"Crystal 30" quantity:0.5];
  [self addMalt:@"Crystal 60" quantity:0.5];
  [self addMalt:@"Crystal 120" quantity:0.5];

  [self.delegate tableView:self.tableView didSelectRowAtIndexPath:self.r2s0];

  XCTAssertThrows([self.delegate tableView:self.tableView moveRowAtIndexPath:self.r0s0 toIndexPath:self.r1s0]);
}

@end
