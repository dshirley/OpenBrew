//
//  OBMainViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/17/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBMainViewController.h"
#import "OBBaseTestCase.h"
#import "OBRecipeViewController.h"
#import <OCMock/OCMock.h>

@interface OBMainViewControllerTest : OBBaseTestCase
@property (nonatomic) OBMainViewController *vc;
@end

@implementation OBMainViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"main"];
  self.vc.settings = self.settings;
  self.vc.moc = self.ctx;
}

- (void)testViewDidLoad
{
  (void)self.vc.view;

  XCTAssertNotNil(self.vc.addRecipeButton);
  XCTAssertNotNil(self.vc.pageViewController);
  XCTAssertNotNil(self.vc.segmentedControl);
  XCTAssertEqualObjects(@"Main Screen", self.vc.screenName);

  XCTAssertEqual(OBCalculationsViewController.class, self.vc.calculationsViewController.class);
  XCTAssertEqual(OBRecipeListViewController.class, self.vc.recipeListViewControler.class);
  XCTAssertEqual(self.settings, self.vc.recipeListViewControler.settings);
  XCTAssertEqual(self.ctx, self.vc.recipeListViewControler.managedObjectContext);
  XCTAssertNotNil(self.vc.calculationsViewController);

  XCTAssertEqual(0, self.vc.segmentedControl.selectedSegmentIndex);
  XCTAssertEqualObjects(@"Recipes", [self.vc.segmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@"Calculations", [self.vc.segmentedControl titleForSegmentAtIndex:1]);

  XCTAssertEqualObjects((@[self.vc.recipeListViewControler]), self.vc.pageViewController.viewControllers);
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

- (void)testSwitchTableViewDataSource_toRecipes
{
  (void)self.vc.view;

  self.vc.navigationItem.title = @"Replace this";
  self.vc.navigationItem.rightBarButtonItem = nil;

  id mockPageViewController = [OCMockObject partialMockForObject:self.vc.pageViewController];
  [[mockPageViewController expect] setViewControllers:@[ self.vc.recipeListViewControler ]
                                            direction:UIPageViewControllerNavigationDirectionReverse
                                             animated:YES
                                           completion:nil];

  self.vc.segmentedControl.selectedSegmentIndex = 0;
  [self.vc.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

    XCTAssertEqualObjects(@"Recipes", [self.vc.segmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@"Recipes", self.vc.navigationItem.title);
  XCTAssertNotNil(self.vc.navigationItem.rightBarButtonItem);

  [mockPageViewController verify];
}

- (void)testSwitchTableViewDataSource_toCalculations
{
  (void)self.vc.view;

  self.vc.navigationItem.title = @"Replace this";

  XCTAssertNotNil(self.vc.navigationItem.rightBarButtonItem);

  id mockPageViewController = [OCMockObject partialMockForObject:self.vc.pageViewController];
  [[mockPageViewController expect] setViewControllers:@[ self.vc.calculationsViewController ]
                                            direction:UIPageViewControllerNavigationDirectionForward
                                             animated:YES
                                           completion:nil];

  XCTAssertEqualObjects(@"Calculations", [self.vc.segmentedControl titleForSegmentAtIndex:1]);
  self.vc.segmentedControl.selectedSegmentIndex = 1;
  [self.vc.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

  XCTAssertEqualObjects(@"Calculations", self.vc.navigationItem.title);
  XCTAssertNil(self.vc.navigationItem.rightBarButtonItem);

  [mockPageViewController verify];
}

- (void)testSwitchTableViewDataSource_invalidIndex
{
  (void)self.vc.view;

  id mockSegmentedControl = [OCMockObject partialMockForObject:self.vc.segmentedControl];
  [[[mockSegmentedControl stub] andReturnValue:OCMOCK_VALUE(2)] selectedSegmentIndex];

  XCTAssertThrows([self.vc.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged]);

  [mockSegmentedControl verify];
}

@end
