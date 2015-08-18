//
//  OBIngredientTableViewDataSourceTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/13/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBIngredientTableViewDataSource.h"
#import <OCMock/OCMock.h>
#import "OBMalt.h"

@interface OBIngredientTableViewDataSourceTest : OBBaseTestCase
@property (nonatomic) NSArray *alphabet;
@property (nonatomic) UITableView *dummyTableView;
@end

@implementation OBIngredientTableViewDataSourceTest

- (void)setUp {
  [super setUp];

  self.dummyTableView = [[UITableView alloc] initWithFrame:CGRectZero];
  self.alphabet = @[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z" ];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testIngredientAtIndexPath
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  NSIndexPath *r0s1 = [NSIndexPath indexPathForRow:0 inSection:1];
  OBMalt *malt = [dataSource ingredientAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Acid Malt", malt.name);

  malt = [dataSource ingredientAtIndexPath:r0s1];
  XCTAssertEqualObjects(@"Barley (flaked)", malt.name);
}

- (void)testNumberOfRowsInSection
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  // Number of malts that start with the letter 'A'
  XCTAssertEqual(3, [dataSource tableView:self.dummyTableView numberOfRowsInSection:0]);
  XCTAssertEqual(8, [dataSource tableView:self.dummyTableView numberOfRowsInSection:1]);

  dataSource.predicate = [NSPredicate predicateWithFormat:@"name == 'Maris Otter'"];
  XCTAssertEqual(1, [dataSource tableView:self.dummyTableView numberOfRowsInSection:0]);
}

- (void)testCellForRowAtIndexPath
{
  UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero];

  id mockTableView = [OCMockObject mockForClass:UITableView.class];
  [[[mockTableView stub] andReturn:cell] dequeueReusableCellWithIdentifier:@"IngredientListCell" forIndexPath:self.r0s0];

  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  UITableViewCell *returnedCell = [dataSource tableView:mockTableView cellForRowAtIndexPath:self.r0s0];

  XCTAssertEqual(cell, returnedCell);
  XCTAssertEqualObjects(@"Acid Malt", cell.textLabel.text);
}

- (void)testNumberOfSectionsInTableView
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  XCTAssertEqual(15, [dataSource numberOfSectionsInTableView:self.dummyTableView]);

  dataSource.predicate = [NSPredicate predicateWithFormat:@"type == 1234"];
  XCTAssertEqual(0, [dataSource numberOfSectionsInTableView:self.dummyTableView]);
}

- (void)testTitleForHeaderInSection
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  // Spot check a few
  XCTAssertEqualObjects(@"A", [dataSource tableView:self.dummyTableView titleForHeaderInSection:0]);
  XCTAssertEqualObjects(@"B", [dataSource tableView:self.dummyTableView titleForHeaderInSection:1]);
  XCTAssertEqualObjects(@"C", [dataSource tableView:self.dummyTableView titleForHeaderInSection:2]);
  XCTAssertEqualObjects(@"D", [dataSource tableView:self.dummyTableView titleForHeaderInSection:3]);

  for (NSInteger i = 0; i < [dataSource numberOfSectionsInTableView:self.dummyTableView]; i++) {
    NSString *title = [dataSource tableView:self.dummyTableView titleForHeaderInSection:i];
    XCTAssertEqual(1, title.length);
    XCTAssertNotEqual(NSNotFound, [self.alphabet indexOfObject:title]);
  }
}

- (void)testTitleForHeaderInSectionWithSingleMatch
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];
  dataSource.predicate = [NSPredicate predicateWithFormat:@"name == 'Maris Otter'"];

  XCTAssertEqualObjects(@"M", [dataSource tableView:self.dummyTableView titleForHeaderInSection:0]);
}

- (void)testSectionIndexTitles
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  XCTAssertEqualObjects((@[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z" ]), [dataSource sectionIndexTitlesForTableView:self.dummyTableView]);
}

- (void)testSectionForSectionIndexTitleAtIndex
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  XCTAssertEqual(0, [dataSource tableView:self.dummyTableView sectionForSectionIndexTitle:@"A" atIndex:999]);
  XCTAssertEqual(1, [dataSource tableView:self.dummyTableView sectionForSectionIndexTitle:@"B" atIndex:999]);
  XCTAssertEqual(2, [dataSource tableView:self.dummyTableView sectionForSectionIndexTitle:@"C" atIndex:999]);

  XCTAssertEqual(3, [dataSource tableView:self.dummyTableView sectionForSectionIndexTitle:@"D" atIndex:999]);

  XCTAssertEqual(4, [dataSource tableView:self.dummyTableView sectionForSectionIndexTitle:@"E" atIndex:999]);
  XCTAssertEqual(4, [dataSource tableView:self.dummyTableView sectionForSectionIndexTitle:@"F" atIndex:999]);
  XCTAssertEqual(4, [dataSource tableView:self.dummyTableView sectionForSectionIndexTitle:@"G" atIndex:999]);
  XCTAssertEqual(5, [dataSource tableView:self.dummyTableView sectionForSectionIndexTitle:@"H" atIndex:999]);

  XCTAssertEqual(14, [dataSource tableView:self.dummyTableView sectionForSectionIndexTitle:@"Z" atIndex:999]);
}

@end
