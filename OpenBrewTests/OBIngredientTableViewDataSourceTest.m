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
@end

@implementation OBIngredientTableViewDataSourceTest

- (void)setUp {
  [super setUp];

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
  XCTAssertEqual(3, [dataSource tableView:nil numberOfRowsInSection:0]);
  XCTAssertEqual(8, [dataSource tableView:nil numberOfRowsInSection:1]);

  dataSource.predicate = [NSPredicate predicateWithFormat:@"name == 'Maris Otter'"];
  XCTAssertEqual(1, [dataSource tableView:nil numberOfRowsInSection:0]);
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

  XCTAssertEqual(15, [dataSource numberOfSectionsInTableView:nil]);

  dataSource.predicate = [NSPredicate predicateWithFormat:@"type == 1234"];
  XCTAssertEqual(0, [dataSource numberOfSectionsInTableView:nil]);
}

- (void)testTitleForHeaderInSection
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  // Spot check a few
  XCTAssertEqualObjects(@"A", [dataSource tableView:nil titleForHeaderInSection:0]);
  XCTAssertEqualObjects(@"B", [dataSource tableView:nil titleForHeaderInSection:1]);
  XCTAssertEqualObjects(@"C", [dataSource tableView:nil titleForHeaderInSection:2]);
  XCTAssertEqualObjects(@"D", [dataSource tableView:nil titleForHeaderInSection:3]);

  for (NSInteger i = 0; i < [dataSource numberOfSectionsInTableView:nil]; i++) {
    NSString *title = [dataSource tableView:nil titleForHeaderInSection:i];
    XCTAssertEqual(1, title.length);
    XCTAssertNotEqual(NSNotFound, [self.alphabet indexOfObject:title]);
  }
}

- (void)testTitleForHeaderInSectionWithSingleMatch
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];
  dataSource.predicate = [NSPredicate predicateWithFormat:@"name == 'Maris Otter'"];

  XCTAssertEqualObjects(@"M", [dataSource tableView:nil titleForHeaderInSection:0]);
}

- (void)testSectionIndexTitles
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  XCTAssertEqualObjects((@[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z" ]), [dataSource sectionIndexTitlesForTableView:nil]);
}

- (void)testSectionForSectionIndexTitleAtIndex
{
  OBIngredientTableViewDataSource *dataSource = [[OBIngredientTableViewDataSource alloc] initIngredientEntityName:@"Malt" andManagedObjectContext:self.ctx];

  XCTAssertEqual(0, [dataSource tableView:nil sectionForSectionIndexTitle:@"A" atIndex:999]);
  XCTAssertEqual(1, [dataSource tableView:nil sectionForSectionIndexTitle:@"B" atIndex:999]);
  XCTAssertEqual(2, [dataSource tableView:nil sectionForSectionIndexTitle:@"C" atIndex:999]);

  XCTAssertEqual(3, [dataSource tableView:nil sectionForSectionIndexTitle:@"D" atIndex:999]);

  XCTAssertEqual(4, [dataSource tableView:nil sectionForSectionIndexTitle:@"E" atIndex:999]);
  XCTAssertEqual(4, [dataSource tableView:nil sectionForSectionIndexTitle:@"F" atIndex:999]);
  XCTAssertEqual(4, [dataSource tableView:nil sectionForSectionIndexTitle:@"G" atIndex:999]);
  XCTAssertEqual(5, [dataSource tableView:nil sectionForSectionIndexTitle:@"H" atIndex:999]);

  XCTAssertEqual(14, [dataSource tableView:nil sectionForSectionIndexTitle:@"Z" atIndex:999]);
}

@end
