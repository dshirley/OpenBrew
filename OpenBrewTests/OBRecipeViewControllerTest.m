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
#import "OBRecipeNavigationController.h"
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

//  OBAppDelegate *delegate = [UIApplication sharedApplication].delegate;
//  OBRecipeNavigationController *navController = (OBRecipeNavigationController *)delegate.window.rootViewController;
//  navController.moc = self.ctx;
//
//  NSLog(@"%@", navController);
  OBRecipeNavigationController *navController = [[OBRecipeNavigationController alloc] init];
  navController.moc = self.ctx;

  self.mockVc = [OCMockObject partialMockForObject:self.vc];
  [[[self.mockVc stub] andReturn:navController] navigationController];

  XCTAssertEqual(self.ctx, [(id)self.vc moc]);
}

- (void)tearDown {
  [self.mockVc stopMocking];
  [super tearDown];
}

- (void)testTableViewNumberOfRowsInSection
{
  [self.vc loadView];

  // One recipe is created by the OBBaseTestCase
  XCTAssertEqual(1, [self.vc tableView:nil numberOfRowsInSection:0]);
//  XCTAssertEqual(0, [self.vc tableView:nil numberOfRowsInSection:1]);
}


// Methods to test
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;


@end
