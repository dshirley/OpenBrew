//
//  OBRecipeListTableViewDataSourceTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBRecipeListViewController.h"
#import "OBRecipeListTableViewDataSource.h"

@interface OBRecipeListTableViewDataSourceTest : OBBaseTestCase
@property (nonatomic) UITableView *tableView;
@property (nonatomic) OBRecipeListTableViewDataSource *dataSource;
@end

@implementation OBRecipeListTableViewDataSourceTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  OBRecipeListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"recipeList"];
  vc.moc = self.ctx;
  
  // Load the view controller
  (void)vc.view;

  // We need to load a table that has the prototype cells that the source uses
  self.tableView = vc.tableView;
  self.dataSource = (id)self.tableView.dataSource;
}


- (void)testTableViewNumberOfRowsInSection
{
  // One recipe is created by the OBBaseTestCase
  XCTAssertEqual(1, [self.dataSource tableView:self.tableView numberOfRowsInSection:0]);

  [[OBRecipe alloc] initWithContext:self.ctx].name = @"A";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"B";
  [self.ctx save:nil];

  XCTAssertEqual(3, [self.dataSource tableView:self.tableView numberOfRowsInSection:0]);
}

- (void)testDeleteRecipe
{
  __block BOOL didCallDeleteCallback = NO;

  self.dataSource.rowDeletedCallback = ^() { didCallDeleteCallback = YES; };

  // Set up some keys to be observed
  [self addMalt:@"Crystal 60" quantity:5.0];
  [self addHops:@"Admiral" quantity:1.0 aaPercent:8.0 boilTime:60];
  [self addYeast:@"WLP001"];

  [self.dataSource tableView:self.tableView
          commitEditingStyle:UITableViewCellEditingStyleDelete
           forRowAtIndexPath:self.r0s0];

  XCTAssertEqual(0, [self.dataSource tableView:nil numberOfRowsInSection:0]);
  XCTAssertEqual(0, [self fetchAllEntity:@"Recipe"].count);
  XCTAssertNil(self.recipe.managedObjectContext);
  XCTAssertTrue(didCallDeleteCallback);
}

- (void)testDeleteOneOfTwoRecipes
{
  NSError *error = nil;
  OBRecipe *testRecipe = [[OBRecipe alloc] initWithContext:self.ctx];
  testRecipe.name = @"testDeleteOneOfTwoRecipes Recipe";
  [self.ctx save:&error];
  XCTAssertNil(error);

  __block BOOL didCallDeleteCallback = NO;
  self.dataSource.rowDeletedCallback = ^() { didCallDeleteCallback = YES; };

  [self.dataSource tableView:self.tableView
          commitEditingStyle:UITableViewCellEditingStyleDelete
           forRowAtIndexPath:self.r1s0];

  XCTAssertEqual(1, [self.dataSource tableView:nil numberOfRowsInSection:0]);
  XCTAssertEqual(1, [self fetchAllEntity:@"Recipe"].count);
  XCTAssertEqual(self.ctx, self.recipe.managedObjectContext);
  XCTAssertNil(testRecipe.managedObjectContext);
  XCTAssertTrue(didCallDeleteCallback);
}

- (void)testCellForRowAtIndexPath
{
  NSError *error = nil;

  // Deliberately generate the recipes in an odd order.
  // They should be in sorted order when we look at the rows
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"B";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"C";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"A";
  self.recipe.name = @"D";

  [self.ctx save:&error]; XCTAssertNil(error);

  UITableViewCell *cell = nil;
  cell = [self.dataSource tableView:self.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(cell.textLabel.text, @"A");

  cell = [self.dataSource tableView:self.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(cell.textLabel.text, @"B");

  cell = [self.dataSource tableView:self.tableView cellForRowAtIndexPath:self.r2s0];
  XCTAssertEqualObjects(cell.textLabel.text, @"C");

  cell = [self.dataSource tableView:self.tableView cellForRowAtIndexPath:self.r3s0];
  XCTAssertEqualObjects(cell.textLabel.text, @"D");
}

@end
