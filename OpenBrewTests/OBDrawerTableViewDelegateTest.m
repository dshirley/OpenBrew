//
//  OBDrawerTableViewDelegateTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/25/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBDrawerTableViewDelegate.h"

@interface OBDrawerTableViewDelegateTest : XCTestCase

@end

@implementation OBDrawerTableViewDelegateTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testIngredientData
{
  OBDrawerTableViewDelegate *delegate = [[OBDrawerTableViewDelegate alloc] initWithGACategory:@"test"];
  XCTAssertThrows([delegate ingredientData]);
}

- (void)testPopulateIngredientCellWithIngredientData
{
  OBDrawerTableViewDelegate *delegate = [[OBDrawerTableViewDelegate alloc] initWithGACategory:@"test"];
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
  XCTAssertThrows([delegate populateIngredientCell:cell withIngredientData:@"fake data"]);
}

- (void)testPopulateDrawerCellWithIngredientData
{
  OBDrawerTableViewDelegate *delegate = [[OBDrawerTableViewDelegate alloc] initWithGACategory:@"test"];
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
  XCTAssertThrows([delegate populateDrawerCell:cell withIngredientData:@"fake data"]);
}


@end
