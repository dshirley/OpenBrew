//
//  OBYeastAdditionViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/18/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBYeastAdditionViewController.h"
#import <OCMock/OCMock.h>
#import "OBIngredientGauge.h"
#import "OBRecipe.h"
#import "OBYeast.h"
#import "OBYeastAddition.h"

@interface OBYeastAdditionViewControllerTest : OBBaseTestCase
@property (nonatomic) OBYeastAdditionViewController *vc;
@end

@implementation OBYeastAdditionViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"yeastAdditionView"];
  self.vc.recipe = self.recipe;
}

- (void)tearDown {
  [super tearDown];
}




//- (void)viewDidLoad
//{
//  [super viewDidLoad];
//
//  self.screenName = OBGAScreenName;
//
//  self.brewery = [OBBrewery breweryFromContext:self.recipe.managedObjectContext];
//
//  self.segmentedController = [[OBSegmentedController alloc] initWithSegmentedControl:self.segmentedControl
//                                                               googleAnalyticsAction:@"Yeast Filter"];
//
//  OBYeastAdditionViewController *weakSelf = self;
//
//  [self.segmentedController addSegment:@"White Labs" actionWhenSelected:^(void) {
//    weakSelf.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWhiteLabs);
//    [weakSelf reloadTableSelectedManufacturer:OBYeastManufacturerWhiteLabs
//                         scrollToSelectedItem:NO];
//  }];
//
//  [self.segmentedController addSegment:@"Wyeast" actionWhenSelected:^(void) {
//    weakSelf.brewery.selectedYeastManufacturer = @(OBYeastManufacturerWyeast);
//    [weakSelf reloadTableSelectedManufacturer:OBYeastManufacturerWyeast
//                         scrollToSelectedItem:NO];
//  }];
//
//  OBYeastManufacturer startingManufacturer = NSNotFound;
//  if (self.recipe.yeast) {
//    startingManufacturer = [self.recipe.yeast.yeast.manufacturer integerValue];
//  } else {
//    startingManufacturer = [self.brewery.selectedYeastManufacturer integerValue];
//  }
//
//  // Selected segment index is in the order in which we add them above
//  if (OBYeastManufacturerWyeast == startingManufacturer) {
//    self.segmentedControl.selectedSegmentIndex = 1;
//  } else {
//    self.segmentedControl.selectedSegmentIndex = 0;
//  }
//
//  [weakSelf reloadTableSelectedManufacturer:startingManufacturer scrollToSelectedItem:YES];
//  [self.gauge refresh];
//}

- (void)testViewDidLoad
{
  [self addMalt:@"Marris Otter" quantity:10.0];
  [self addYeast:@"WLP001"];

  id mockGauge = [OCMockObject partialMockForObject:self.vc.gauge];
  [[mockGauge expect] refresh];

  [self.vc loadView];
  [self.vc viewDidLoad];

  XCTAssertEqual(1, [self.vc.tableView numberOfSections]);
  XCTAssertGreaterThan(0, [self.vc.tableView numberOfRowsInSection:0]);

  XCTAssertEqual(2, [self.vc.segmentedControl numberOfSegments]);
  XCTAssertEqualObjects(@"White Labs", [self.vc.segmentedControl titleForSegmentAtIndex:0]);
  XCTAssertEqualObjects(@"Wyeast", [self.vc.segmentedControl titleForSegmentAtIndex:1]);

  XCTAssertEqual(OBMetricFinalGravity, self.vc.gauge.metricToDisplay);

  UITableViewCell *cell = [self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertTrue(cell.selected);

  [mockGauge verify];
}





//
//#pragma mark UITableViewDelegate methods
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//
//#pragma mark UITableViewDataSource methods
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
