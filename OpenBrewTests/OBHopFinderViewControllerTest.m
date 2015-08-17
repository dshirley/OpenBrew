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

  XCTAssertGreaterThan([self.vc.tableView numberOfSections], 0);
  XCTAssertGreaterThan([self.vc.tableView numberOfRowsInSection:0], 0);
}

- (void)testViewWillAppear
{
  [self.vc loadView];
  [self.vc viewWillAppear:NO];

  XCTAssertEqualObjects(@"Hop Finder Screen", self.vc.screenName);
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
  XCTAssertEqualObjects(@"Bramling Cross", hopAddition.hops.name);
}

@end
