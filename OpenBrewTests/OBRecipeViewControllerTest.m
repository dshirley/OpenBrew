//
//  OBRecipeViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/29/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBRecipeViewController.h"
#import "OBRecipeOverviewController.h"
#import <OCMock/OCMock.h>
#import "OBAppDelegate.h"

@interface OBRecipeViewControllerTest : OBBaseTestCase
@property (nonatomic) OBRecipeViewController *vc;
@property (nonatomic) id mockVc;
@end

@implementation OBRecipeViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"recipeList"];
  self.vc.moc = self.ctx;
  self.vc.settings = self.settings;
}

- (void)tearDown {
  [self.mockVc stopMocking];
  [super tearDown];
}

- (void)testViewDidLoad
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertFalse(self.vc.firstInteractionComplete);
  XCTAssertEqualWithAccuracy(CFAbsoluteTimeGetCurrent(), self.vc.loadTime, 0.5);
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

- (void)testTableViewNumberOfRowsInSection
{
  [self.vc loadView];

  // One recipe is created by the OBBaseTestCase
  XCTAssertEqual(1, [self.vc tableView:nil numberOfRowsInSection:0]);

  [[OBRecipe alloc] initWithContext:self.ctx].name = @"A";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"B";

  XCTAssertEqual(3, [self.vc tableView:nil numberOfRowsInSection:0]);
}

- (void)testDeleteRecipe
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] switchToEmptyTableViewMode];

  [self.vc loadView];

  // Set up some keys to be observed
  [self addMalt:@"Crystal 60" quantity:5.0];
  [self addHops:@"Admiral" quantity:1.0 aaPercent:8.0 boilTime:60];
  [self addYeast:@"WLP001"];

  [self.vc tableView:self.vc.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:self.r0s0];
  
  XCTAssertEqual(0, [self.vc tableView:nil numberOfRowsInSection:0]);
  XCTAssertEqual(0, [self fetchAllEntity:@"Recipe"].count);
  XCTAssertNil(self.recipe.managedObjectContext);

  [mockVc verify];
}

// Make sure the "no recipes" view does not get displayed
- (void)testDeleteOneOfTwoRecipes
{
  OBRecipe *testRecipe = [[OBRecipe alloc] initWithContext:self.ctx];
  testRecipe.name = @"testDeleteOneOfTwoRecipes Recipe";

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] switchToEmptyTableViewMode];

  [self.vc loadView];

  [self.vc tableView:self.vc.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:self.r1s0];

  XCTAssertEqual(1, [self.vc tableView:nil numberOfRowsInSection:0]);
  XCTAssertEqual(1, [self fetchAllEntity:@"Recipe"].count);
  XCTAssertEqual(self.ctx, self.recipe.managedObjectContext);
  XCTAssertNil(testRecipe.managedObjectContext);

  XCTAssertThrows([mockVc verify]);
}

- (void)testCellForRowAtIndexPath
{
  // Deliberately generate the recipes in an odd order.
  // They should be in sorted order when we look at the rows
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"B";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"C";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"A";
  self.recipe.name = @"D";

  [self.vc loadView];

  UITableViewCell *cell = nil;
  cell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(cell.textLabel.text, @"A");

  cell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(cell.textLabel.text, @"B");

  cell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r2s0];
  XCTAssertEqualObjects(cell.textLabel.text, @"C");

  cell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r3s0];
  XCTAssertEqualObjects(cell.textLabel.text, @"D");
}

- (void)testPrepareForSegue_AddRecipe
{
  OBRecipeOverviewController *dest = [[OBRecipeOverviewController alloc] init];

  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"addRecipe" source:self.vc destination:dest];
  
  XCTAssertFalse(self.vc.firstInteractionComplete);

  [self.vc prepareForSegue:segue sender:[NSNull null]];

  NSArray *recipes = [self fetchAllEntity:@"Recipe"];
  XCTAssertEqual(2, recipes.count);
  XCTAssertTrue([recipes containsObject:self.recipe]);
  XCTAssertTrue([recipes containsObject:dest.recipe]);

  XCTAssertEqualObjects(@"New Recipe", dest.recipe.name);
  XCTAssertTrue(self.vc.firstInteractionComplete);

  XCTAssertEqual(self.settings, dest.settings);
}

- (void)testPrepareForSegue_SelectRecipe
{
  [self.vc loadView];

  OBRecipeOverviewController *dest = [[OBRecipeOverviewController alloc] init];
  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"selectRecipe" source:self.vc destination:dest];
  NSObject *dummySender = [[NSObject alloc] init];

  id mockTableView = [OCMockObject partialMockForObject:self.vc.tableView];
  [[[mockTableView stub] andReturn:self.r0s0] indexPathForCell:(id)dummySender];

  XCTAssertFalse(self.vc.firstInteractionComplete);

  [self.vc prepareForSegue:segue sender:dummySender];

  NSArray *recipes = [self fetchAllEntity:@"Recipe"];
  XCTAssertEqual(1, recipes.count);
  XCTAssertTrue([recipes containsObject:self.recipe]);

  XCTAssertEqual(self.recipe, dest.recipe);
  XCTAssertTrue(self.vc.firstInteractionComplete);

  [mockTableView verify];

  XCTAssertEqual(self.settings, dest.settings);
}

@end
