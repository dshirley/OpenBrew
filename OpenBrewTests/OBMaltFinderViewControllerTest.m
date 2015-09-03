//
//  OBMaltFinderViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBMaltFinderViewController.h"
#import "OBBaseTestCase.h"
#import "OBMaltAddition.h"
#import "OBMalt.h"
#import "OBIngredientTableViewDataSource.h"
#import <OCMock/OCMock.h>


@interface OBMaltFinderViewControllerTest : OBBaseTestCase
@property (nonatomic) OBMaltFinderViewController *vc;
@end

@implementation OBMaltFinderViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"maltFinderView"];
  self.vc.recipe = self.recipe;
}

- (void)testViewDidLoad
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertNotNil(self.vc.tableView.dataSource);
  XCTAssertNil(self.vc.tableView.delegate);

  XCTAssertGreaterThan([self.vc.tableView numberOfSections], 0);
  XCTAssertGreaterThan([self.vc.tableView numberOfRowsInSection:0], 0);

  OBIngredientTableViewDataSource *dataSource = self.vc.tableView.dataSource;
  XCTAssertEqualObjects(@"type == 0", dataSource.predicate.predicateFormat);
}

- (void)testViewWillAppear
{
  [self.vc loadView];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Malt Finder Screen", self.vc.screenName);
}

- (void)testApplyMaltTypeFilter
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockSegmentedControl = [OCMockObject mockForClass:UISegmentedControl.class];
  [[[mockSegmentedControl stub] andReturnValue:OCMOCK_VALUE(1)] selectedSegmentIndex];

  NSInteger numSectionsBefore = [self.vc.tableView numberOfSections];
  [self.vc applyMaltTypeFilter:mockSegmentedControl];
  NSInteger numSectionsAfter = [self.vc.tableView numberOfSections];

  XCTAssertNotEqual(numSectionsBefore, numSectionsAfter);

  OBIngredientTableViewDataSource *dataSource = self.vc.tableView.dataSource;

  XCTAssertEqualObjects(@"type == 2", dataSource.predicate.predicateFormat);
}

- (void)testApplyInvalidFilter
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  id mockSegmentedControl = [OCMockObject mockForClass:UISegmentedControl.class];
  [[[mockSegmentedControl stub] andReturnValue:OCMOCK_VALUE(3)] selectedSegmentIndex];

  XCTAssertThrows([self.vc applyMaltTypeFilter:mockSegmentedControl]);
}

- (void)testSelectSegment
{
  [self.vc loadView];
  [self.vc viewDidLoad];

  self.vc.segmentedControl.selectedSegmentIndex = 2;
  [self.vc.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];

  OBIngredientTableViewDataSource *dataSource = self.vc.tableView.dataSource;

  // Selected malt type "sugar"
  XCTAssertEqualObjects(@"type == 1", dataSource.predicate.predicateFormat);
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

  XCTAssertEqual(1, self.recipe.maltAdditions.count);

  OBMaltAddition *maltAddition = [self.recipe.maltAdditions anyObject];
  XCTAssertEqualObjects(@"Biscuit", maltAddition.name);
}

@end
