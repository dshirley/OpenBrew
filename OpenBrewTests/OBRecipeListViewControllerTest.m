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
#import "OBRecipeListViewController.h"
#import "OBRecipeViewController.h"
#import <OCMock/OCMock.h>
#import "OBAppDelegate.h"
#import "OBRecipeListTableViewDataSource.h"

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


  OBRecipeListTableViewDataSource *dataSource = self.vc.tableView.dataSource;
  XCTAssertNotNil(dataSource);
  XCTAssertEqual(OBRecipeListTableViewDataSource.class, dataSource.class);
  XCTAssertNotNil(dataSource.rowDeletedCallback);
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

  OBRecipeListTableViewDataSource *dataSource = (id)self.vc.tableView.dataSource;
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
  
  XCTAssertFalse(self.vc.firstInteractionComplete);

  [self.vc prepareForSegue:segue sender:[NSNull null]];

  NSArray *recipes = [self fetchAllEntity:@"Recipe"];
  XCTAssertEqual(2, recipes.count);
  XCTAssertTrue([recipes containsObject:self.recipe]);
  XCTAssertTrue([recipes containsObject:dest.recipe]);

  XCTAssertEqualObjects(@"New Recipe", dest.recipe.name);
  XCTAssertEqualObjects(self.settings.defaultPreBoilSize, self.recipe.preBoilVolumeInGallons);
  XCTAssertEqualObjects(self.settings.defaultPostBoilSize, self.recipe.postBoilVolumeInGallons);

  XCTAssertTrue(self.vc.firstInteractionComplete);

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
