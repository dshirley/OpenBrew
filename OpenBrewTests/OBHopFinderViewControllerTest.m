//
//  OBHopFinderViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBHopFinderViewController.h"
#import "OBBaseTestCase.h"
#import "OBHopAddition.h"
#import "OBHops.h"
#import "OBIngredientTableViewDataSource.h"
#import <OCMock/OCMock.h>


@interface OBHopFinderViewControllerTest : OBBaseTestCase
@property (nonatomic) OBHopFinderViewController *vc;
@end

@implementation OBHopFinderViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"hopFinderView"];
  self.vc.recipe = self.recipe;

  XCTAssertNotNil(self.vc);
}

- (void)testViewDidLoad
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertNotNil(self.vc.tableView.dataSource);
  XCTAssertNil(self.vc.tableView.delegate);


  NSArray *indexTitles = [self.vc.tableView.dataSource sectionIndexTitlesForTableView:self.vc.tableView];
  XCTAssertEqualObjects(@"A", indexTitles[0]);

  NSInteger sectionA = [self.vc.tableView.dataSource tableView:self.vc.tableView
                                   sectionForSectionIndexTitle:@"A"
                                                       atIndex:0];

  XCTAssertEqual(0, sectionA);


  XCTAssertGreaterThan([self.vc.tableView numberOfSections], 0);

  NSInteger numRows = [self.vc.tableView numberOfRowsInSection:0];
  XCTAssertGreaterThan(numRows, 0);

  // Check that HopAdditions do not show up in the hop finder view
  // (HopAdditions inherit from Hops, which means a bug is liable to happen
  // if code is not explicitly written to make HopAdditions not appear in the list)
  [self addHops:@"Admiral" quantity:1.0 aaPercent:10.0 boilTime:60];

  XCTAssertEqual(numRows, [self.vc.tableView numberOfRowsInSection:0]);

  XCTAssertNotNil(self.vc.searchController);
  XCTAssertEqual(0, self.vc.searchController.searchBar.text.length);
}

- (void)testViewWillAppear
{
  [self.vc loadView];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Hop Finder Screen", self.vc.screenName);
}

- (void)testSearchText
{
  [self.vc loadView];
  [self.vc viewDidLoad];
  [self.vc.searchController.searchBar setText:@"cascade"];
  XCTAssertEqual(1, [self.vc.tableView numberOfSections]);

  [self.vc.searchController.searchBar setText:nil];
  XCTAssertGreaterThan(self.vc.tableView.numberOfSections, 1);
}

- (void)testPrepareForSegue
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockSegue = [OCMockObject mockForClass:UIStoryboardSegue.class];
  [[[mockSegue stub] andReturn:@"IngredientSelected"] identifier];

  NSIndexPath *r1s1 = [NSIndexPath indexPathForRow:1 inSection:1];
  UITableViewCell *cell = [self.vc.tableView cellForRowAtIndexPath:r1s1];

  [self.vc prepareForSegue:mockSegue sender:cell];

  XCTAssertEqual(1, self.recipe.hopAdditions.count);

  OBHopAddition *hopAddition = [self.recipe.hopAdditions anyObject];
  XCTAssertEqualObjects(@"Bramling Cross", hopAddition.name);
}

@end
