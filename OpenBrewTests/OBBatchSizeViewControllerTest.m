//
//  OBBatchSizeViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBBatchSizeViewController.h"
#import "OBBatchSizeTableViewDelegate.h"
#import <OCMock/OCMock.h>

@interface OBBatchSizeViewControllerTest : OBBaseTestCase
@property (nonatomic) OBBatchSizeViewController *vc;
@end

@implementation OBBatchSizeViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"batchSizeScene"];
  self.vc.recipe = self.recipe;
}

- (void)testViewDidLoad
{
  [self.vc loadView];

  [self.vc viewDidLoad];

  XCTAssertEqualObjects(@"Batch Size Screen", self.vc.screenName);
  XCTAssertTrue([self.vc.tableView.dataSource isKindOfClass:OBBatchSizeTableViewDelegate.class]);
  XCTAssertTrue([self.vc.tableView.delegate isKindOfClass:OBBatchSizeTableViewDelegate.class]);

  // Make sure data was loaded into the tableview
  XCTAssertEqual(2, [self.vc.tableView numberOfSections]);
  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertEqual(1, [self.vc.tableView numberOfRowsInSection:1]);
}

- (void)testTableViewRefreshesWhenDataChanges
{
  [self.vc loadView];

  id mockTableView = [OCMockObject partialMockForObject:self.vc.tableView];

  [[mockTableView expect] reloadData];
  self.recipe.preBoilVolumeInGallons = @(1.234);
  [mockTableView verify];

  [[mockTableView expect] reloadData];
  self.recipe.postBoilVolumeInGallons = @(5.2398);
  [mockTableView verify];

  [mockTableView stopMocking];
}

@end
