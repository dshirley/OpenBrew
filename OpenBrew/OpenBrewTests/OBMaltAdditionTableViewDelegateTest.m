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

@interface OBMaltAdditionTableViewDelegateTest : OBBaseTestCase
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) OBMaltAdditionTableViewDelegate *delegate;
@end

@implementation OBMaltAdditionTableViewDelegateTest

- (void)setUp {
  [super setUp];

  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 240, 320)];
  self.delegate = [[OBMaltAdditionTableViewDelegate alloc] initWithRecipe:self.recipe
                                                             andTableView:self.tableView
                                                            andGACategory:@"testing"];

  self.tableView.dataSource = self.delegate;
  self.tableView.delegate = self.delegate;

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

  // TODO: test opening the drawer and closing the drawer
}

- (void)testNumberOfSectionsInTableView
{
  XCTAssertEqual([self.delegate numberOfSectionsInTableView:self.tableView], 1);
  [self addMalt:@"Pilsner Malt" quantity:10.0];

  XCTAssertEqual([self.delegate numberOfSectionsInTableView:self.tableView], 1, @"Still no change");
}

// Methods that need testing:

//- (UITableViewCell *)tableView:(UITableView *)tableView
//         cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//forRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
//      toIndexPath:(NSIndexPath *)destinationIndexPath;
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
