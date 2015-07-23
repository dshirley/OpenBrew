//
//  OBRecipeOverviewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/23/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBRecipeOverviewController.h"
#import "OBTextStatisticsCollectionViewCell.h"

@interface OBRecipeOverviewControllerTest : OBBaseTestCase
@property (nonatomic) OBRecipeOverviewController *vc;

// TODO: put these in a super class for convenience
@property (nonatomic) NSIndexPath *r0s0;
@property (nonatomic) NSIndexPath *r1s0;
@property (nonatomic) NSIndexPath *r2s0;
@property (nonatomic) NSIndexPath *r3s0;
@property (nonatomic) NSIndexPath *r4s0;
@property (nonatomic) NSIndexPath *r5s0;

@end

@implementation OBRecipeOverviewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"recipeOverview"];
  self.vc.recipe = self.recipe;

  self.r0s0 = [NSIndexPath indexPathForRow:0 inSection:0];
  self.r1s0 = [NSIndexPath indexPathForRow:1 inSection:0];
  self.r2s0 = [NSIndexPath indexPathForRow:2 inSection:0];
  self.r3s0 = [NSIndexPath indexPathForRow:3 inSection:0];
  self.r4s0 = [NSIndexPath indexPathForRow:4 inSection:0];
  self.r5s0 = [NSIndexPath indexPathForRow:5 inSection:0];
}

- (void)tearDown {
  [super tearDown];
}


- (void)loadView {
  [self.vc performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
}

- (void)testLoadingTableViewEmptyRecipe
{
  [self loadView];

  XCTAssertEqual(4, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertEqual(1, [self.vc.tableView numberOfSections]);

  UITableViewCell *tCell = nil;

  tCell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Batch size", tCell.textLabel.text);
  XCTAssertEqualObjects(@"6.0 gallons", tCell.detailTextLabel.text);

  tCell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"Malts", tCell.textLabel.text);
  XCTAssertEqualObjects(@"0 varieties", tCell.detailTextLabel.text);

  tCell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r2s0];
  XCTAssertEqualObjects(@"Hops", tCell.textLabel.text);
  XCTAssertEqualObjects(@"0 varieties", tCell.detailTextLabel.text);

  tCell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r3s0];
  XCTAssertEqualObjects(@"Yeast", tCell.textLabel.text);
  XCTAssertEqualObjects(@"none", tCell.detailTextLabel.text);
}

- (void)testCollectionViewEmptyRecipe
{
  [self loadView];

  XCTAssertEqual(6, [self.vc collectionView:self.vc.collectionView numberOfItemsInSection:0]);

  OBTextStatisticsCollectionViewCell *statsCell = nil;

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"1.000", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"Original gravity", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"1.000", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"Final gravity", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r2s0];
  XCTAssertEqualObjects(@"0.0%", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"ABV", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r4s0];
  XCTAssertEqualObjects(@"0", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"IBU", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r5s0];
  XCTAssertEqualObjects(@"inf", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"BU:GU", statsCell.descriptionLabel.text);
}

@end
