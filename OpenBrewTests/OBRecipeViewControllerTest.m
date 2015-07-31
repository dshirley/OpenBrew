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

  [[OBRecipe alloc] initWithContext:self.ctx].name = @"A";
  [[OBRecipe alloc] initWithContext:self.ctx].name = @"B";

  XCTAssertEqual(3, [self.vc tableView:nil numberOfRowsInSection:1]);
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
