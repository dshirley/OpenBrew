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


@end
