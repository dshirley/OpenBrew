//
//  OBRecipeListViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/29/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBMainViewController.h"
#import "OBRecipeListViewController.h"
#import "OBRecipeViewController.h"
#import <OCMock/OCMock.h>
#import "OBAppDelegate.h"
#import "OBRecipeTableViewCell.h"

// It's easier to test this
@interface OBRecipeListViewController(Test)
- (void)recipeWasDeleted;
@end

@interface OBRecipeListViewControllerTest : OBBaseTestCase
@property (nonatomic) OBRecipeListViewController *vc;
@property (nonatomic) id mockVc;
@end

@implementation OBRecipeListViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"recipeList"];
  self.vc.managedObjectContext = self.ctx;
  self.vc.settings = self.settings;
}

- (void)tearDown {
  [self.mockVc stopMocking];
  [super tearDown];
}

- (void)testViewDidLoad
{
  (void)self.vc.view;

  XCTAssertEqual(self.vc, self.vc.tableView.dataSource);
}

- (void)testViewWillAppear
{
  [self.vc loadView];

  id mockTableView = [OCMockObject partialMockForObject:self.vc.tableView];
  [[mockTableView expect] reloadData];

  [self.vc viewWillAppear:YES];

  XCTAssertEqualObjects(@"Recipe List Screen", self.vc.screenName);
  XCTAssertNil(self.vc.tableView.tableFooterView);

  [mockTableView verify];
}

- (void)testShowAndRemovePlaceholderView
{
  (void)self.vc.view;

  NSArray *recipes = [self fetchAllEntity:@"Recipe"];

  XCTAssertEqual(1, recipes.count);
  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);

  XCTAssertNotNil(self.vc.placeholderView);
  XCTAssertTrue(self.vc.placeholderView.hidden);
  XCTAssertFalse(self.vc.tableView.hidden);

  id dataSource = (id)self.vc.tableView.dataSource;
  [dataSource tableView:self.vc.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:self.r0s0];

  XCTAssertNotNil(self.vc.placeholderView);
  XCTAssertFalse(self.vc.placeholderView.hidden);
  XCTAssertTrue(self.vc.tableView.hidden);

  (void)[[OBRecipe alloc] initWithContext:self.ctx];

  NSError *error = nil;
  [self.ctx save:&error];
  XCTAssertNil(error);
  
  [self.vc viewWillAppear:NO];

  XCTAssertNotNil(self.vc.placeholderView);
  XCTAssertTrue(self.vc.placeholderView.hidden);
  XCTAssertFalse(self.vc.tableView.hidden);
}

- (void)testPrepareForSegue_AddRecipe
{
  OBRecipeViewController *dest = [[OBRecipeViewController alloc] init];

  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"addRecipe" source:self.vc destination:dest];

  [self.vc prepareForSegue:segue sender:[NSNull null]];

  NSArray *recipes = [self fetchAllEntity:@"Recipe"];
  XCTAssertEqual(2, recipes.count);
  XCTAssertTrue([recipes containsObject:self.recipe]);
  XCTAssertTrue([recipes containsObject:dest.recipe]);

  XCTAssertEqualObjects(@"New Recipe", dest.recipe.name);
  XCTAssertEqualObjects(self.settings.defaultPreBoilSize, self.recipe.preBoilVolumeInGallons);
  XCTAssertEqualObjects(self.settings.defaultPostBoilSize, self.recipe.postBoilVolumeInGallons);

  XCTAssertEqual(self.settings, dest.settings);
}

- (void)testPrepareForSegue_SelectRecipe
{
  (void)self.vc.view;

  OBRecipeViewController *dest = [[OBRecipeViewController alloc] init];
  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"selectRecipe" source:self.vc destination:dest];
  NSObject *dummySender = [[NSObject alloc] init];

  id mockTableView = [OCMockObject partialMockForObject:self.vc.tableView];
  [[[mockTableView stub] andReturn:self.r0s0] indexPathForCell:(id)dummySender];

  [self.vc prepareForSegue:segue sender:dummySender];

  NSArray *recipes = [self fetchAllEntity:@"Recipe"];
  XCTAssertEqual(1, recipes.count);
  XCTAssertTrue([recipes containsObject:self.recipe]);

  XCTAssertEqual(self.recipe, dest.recipe);

  [mockTableView verify];

  XCTAssertEqual(self.settings, dest.settings);
}

- (void)testTableViewNumberOfRowsInSection
{
  (void)self.vc.view;

  // One recipe is created by the OBBaseTestCase
  XCTAssertEqual(1, [self.vc tableView:self.vc.tableView numberOfRowsInSection:0]);

  [[OBRecipe alloc] initWithContext:self.ctx].name = @"A";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"B";
  [self.ctx save:nil];

  XCTAssertEqual(3, [self.vc tableView:self.vc.tableView numberOfRowsInSection:0]);
}

- (void)testDeleteRecipe
{
  (void)self.vc.view;

  // Set up some keys to be observed
  [self addMalt:@"Crystal 60" quantity:5.0];
  [self addHops:@"Admiral" quantity:1.0 aaPercent:8.0 boilTime:60];
  [self addYeast:@"WLP001"];

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] recipeWasDeleted];

  [self.vc tableView:self.vc.tableView
  commitEditingStyle:UITableViewCellEditingStyleDelete
   forRowAtIndexPath:self.r0s0];

  XCTAssertEqual(0, [self.vc tableView:nil numberOfRowsInSection:0]);
  XCTAssertEqual(0, [self fetchAllEntity:@"Recipe"].count);
  XCTAssertNil(self.recipe.managedObjectContext);

  [mockVc verify];
}

- (void)testDeleteOneOfTwoRecipes
{
  (void)self.vc.view;

  NSError *error = nil;
  OBRecipe *testRecipe = [[OBRecipe alloc] initWithContext:self.ctx];
  testRecipe.name = @"testDeleteOneOfTwoRecipes Recipe";
  [self.ctx save:&error];
  XCTAssertNil(error);

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] recipeWasDeleted];

  [self.vc tableView:self.vc.tableView
  commitEditingStyle:UITableViewCellEditingStyleDelete
   forRowAtIndexPath:self.r1s0];

  XCTAssertEqual(1, [self.vc tableView:nil numberOfRowsInSection:0]);
  XCTAssertEqual(1, [self fetchAllEntity:@"Recipe"].count);
  XCTAssertEqual(self.ctx, self.recipe.managedObjectContext);
  XCTAssertNil(testRecipe.managedObjectContext);

  [mockVc verify];
}

- (void)testCellForRowAtIndexPath
{
  (void)self.vc.view;

  NSError *error = nil;

  // Deliberately generate the recipes in an odd order.
  // They should be in sorted order when we look at the rows
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"B";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"C";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"A";
  self.recipe.name = @"D";

  [self.ctx save:&error]; XCTAssertNil(error);

  OBRecipeTableViewCell *cell = nil;
  cell = (id)[self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(cell.recipeName.text, @"A");

  cell = (id)[self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(cell.recipeName.text, @"B");

  cell = (id)[self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r2s0];
  XCTAssertEqualObjects(cell.recipeName.text, @"C");

  cell = (id)[self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r3s0];
  XCTAssertEqualObjects(cell.recipeName.text, @"D");
}

@end
