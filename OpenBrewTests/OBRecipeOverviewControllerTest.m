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
#import "OBColorStatisticsCollectionViewCell.h"
#import "OCMock.h"
#import "OBBrewController.h"
#import "GAI.h"

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

- (void)testViewWillAppearPoppingNavigationStack
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];
  id mockCtx = [OCMockObject partialMockForObject:self.recipe.managedObjectContext];

  [[[mockVc stub] andReturnValue:OCMOCK_VALUE(NO)] isMovingToParentViewController];

  [[mockVc expect] reloadData];

  [[mockCtx expect] save:(id __autoreleasing *)[OCMArg anyPointer]];

  [self.vc viewWillAppear:YES];

  [mockVc verify];
  [mockCtx verify];

  XCTAssertEqualObjects(self.vc.screenName, @"Recipe Overview Screen");
}

- (void)testViewWillAppearPushingNavigationStack
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];
  id mockCtx = [OCMockObject partialMockForObject:self.recipe.managedObjectContext];

  [[[mockVc stub] andReturnValue:OCMOCK_VALUE(YES)] isMovingToParentViewController];

  [[mockVc expect] reloadData];

  [[mockCtx expect] save:(id __autoreleasing *)[OCMArg anyPointer]];

  [self.vc viewWillAppear:YES];

  XCTAssertThrows([mockVc verify]);
  XCTAssertThrows([mockCtx verify]);

  XCTAssertEqualObjects(self.vc.screenName, @"Recipe Overview Screen");
}

- (void)testTextFieldDidEndEditing
{
  [self loadView];

  self.vc.recipeNameTextField.text = @"Broskie Brew";

  id mockCtx = [OCMockObject partialMockForObject:self.recipe.managedObjectContext];
  [[mockCtx expect] save:(id __autoreleasing *)[OCMArg anyPointer]];

  [self.vc textFieldDidEndEditing:self.vc.recipeNameTextField];

  XCTAssertEqualObjects(@"Broskie Brew", self.recipe.name);
  [mockCtx verify];
}

- (void)testTextFieldShouldReturn
{
  UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
  id mockTextField = [OCMockObject partialMockForObject:textField];
  [[mockTextField expect] resignFirstResponder];

  [self.vc textFieldShouldReturn:textField];
  [mockTextField verify];
}

- (void)testViewDidLoad
{
  [self loadView];

  self.recipe.name = @"Drunky pants";

  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] reloadData];

  XCTAssertNil(self.vc.tableView.tableHeaderView);
  XCTAssertEqualObjects(self.vc.recipeNameTextField.text, @"");

  [self.vc viewDidLoad];

  XCTAssertEqualObjects(self.recipe.name, @"Drunky pants");
  XCTAssertNotNil(self.vc.tableView.tableHeaderView);
}

- (void)testPrepareForSegue
{
  id mockDestVc = [OCMockObject mockForProtocol:@protocol(OBBrewController)];
  [[mockDestVc expect] setRecipe:self.recipe];

  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"testid"
                                                                    source:self.vc
                                                               destination:mockDestVc];

  [self.vc prepareForSegue:segue sender:nil];
  [mockDestVc verify];
}

- (void)testTouchesBeganWithEvent
{
  id mockVc = [OCMockObject partialMockForObject:self.vc];
  [[mockVc expect] dismissKeyboard];

  [self.vc touchesBegan:[NSSet set] withEvent:nil];
  [mockVc verify];
}

- (void)addIngredients
{
  // Munich helles extract recipe from Brewing Classic Styles
  // This recipe is also used in the OBRecipeTest
  // We just need something that is standardized for testing the recipe values
  [self addMalt:@"Pilsner LME" quantity:7.6 color:2.3];
  [self addMalt:@"Munich LME" quantity:0.5 color:9];
  [self addMalt:@"Melanoidin Malt" quantity:0.25 color:28];
  [self addHops:@"Hallertau" quantity:1.1 aaPercent:4.0 boilTime:90];
  [self addYeast:@"WLP838"];
  self.recipe.postBoilVolumeInGallons = @(6.0);
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

- (void)testLoadingTableViewFilledOutRecipe
{
  [self addIngredients];
  [self loadView];
  [self assertTableViewFilledOutWithTestData];
}

- (void)testReloadDataUpdatesTableView
{
  [self loadView];
  [self addIngredients];
  [self.vc reloadData];
  [self assertTableViewFilledOutWithTestData];
}

- (void)assertTableViewFilledOutWithTestData
{
  XCTAssertEqual(4, [self.vc.tableView numberOfRowsInSection:0]);
  XCTAssertEqual(1, [self.vc.tableView numberOfSections]);

  UITableViewCell *tCell = nil;

  tCell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"Batch size", tCell.textLabel.text);
  XCTAssertEqualObjects(@"6.0 gallons", tCell.detailTextLabel.text);

  tCell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"Malts", tCell.textLabel.text);
  XCTAssertEqualObjects(@"3 varieties", tCell.detailTextLabel.text);

  tCell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r2s0];
  XCTAssertEqualObjects(@"Hops", tCell.textLabel.text);
  XCTAssertEqualObjects(@"1 variety", tCell.detailTextLabel.text);

  tCell = [self.vc tableView:self.vc.tableView cellForRowAtIndexPath:self.r3s0];
  XCTAssertEqualObjects(@"Yeast", tCell.textLabel.text);
  XCTAssertEqualObjects(@"Southern German Lager", tCell.detailTextLabel.text);
}

- (void)testCollectionViewEmptyRecipe
{
  [self loadView];

  XCTAssertEqual(6, [self.vc collectionView:self.vc.collectionView numberOfItemsInSection:0]);

  OBTextStatisticsCollectionViewCell *statsCell = nil;
  OBColorStatisticsCollectionViewCell *colorCell = nil;

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"1.000", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"Original gravity", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"1.000", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"Final gravity", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r2s0];
  XCTAssertEqualObjects(@"0.0%", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"ABV", statsCell.descriptionLabel.text);

  colorCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r3s0];
  XCTAssertEqual(0, colorCell.colorView.colorInSrm);
  XCTAssertEqualObjects(@"Color", colorCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r4s0];
  XCTAssertEqualObjects(@"0", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"IBU", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r5s0];
  XCTAssertEqualObjects(@"inf", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"BU:GU", statsCell.descriptionLabel.text);
}

- (void)testCollectionViewWithPopulatedRecipe
{
  [self addIngredients];
  [self loadView];
  [self assertCollectionViewFilledOutWithTestData];
}

- (void)testReloadDataUpdatesCollectionView
{
  [self loadView];
  [self addIngredients];
  [self.vc reloadData];
  [self assertCollectionViewFilledOutWithTestData];
}

- (void)assertCollectionViewFilledOutWithTestData
{
  XCTAssertEqual(6, [self.vc collectionView:self.vc.collectionView numberOfItemsInSection:0]);

  OBTextStatisticsCollectionViewCell *statsCell = nil;
  OBColorStatisticsCollectionViewCell *colorCell = nil;

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r0s0];
  XCTAssertEqualObjects(@"1.050", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"Original gravity", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r1s0];
  XCTAssertEqualObjects(@"1.012", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"Final gravity", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r2s0];
  XCTAssertEqualObjects(@"5.0%", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"ABV", statsCell.descriptionLabel.text);

  colorCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r3s0];
  XCTAssertEqual(5, colorCell.colorView.colorInSrm);
  XCTAssertEqualObjects(@"Color", colorCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r4s0];
  XCTAssertEqualObjects(@"14", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"IBU", statsCell.descriptionLabel.text);

  statsCell = (id)[self.vc collectionView:self.vc.collectionView cellForItemAtIndexPath:self.r5s0];
  XCTAssertEqualObjects(@"0.29", statsCell.statisticLabel.text);
  XCTAssertEqualObjects(@"BU:GU", statsCell.descriptionLabel.text);

  // TODO: add color test
}

- (void)testTableViewHeightForRowAtIndexPath
{
  [self loadView];

  for (NSIndexPath *path in @[ self.r0s0, self.r1s0, self.r2s0, self.r3s0 ]) {
    XCTAssertEqual(self.vc.tableView.frame.size.height / 4.0,
                   [self.vc tableView:self.vc.tableView heightForRowAtIndexPath:path]);
  }
}

- (void)testTableViewDidSelectRowAtIndexPath
{
  [self doTestSelectRowAtIndexPath:self.r0s0 expectedSegueId:@"selectedBatchSize"];
  [self doTestSelectRowAtIndexPath:self.r1s0 expectedSegueId:@"selectedMalts"];
  [self doTestSelectRowAtIndexPath:self.r2s0 expectedSegueId:@"selectedHops"];
  [self doTestSelectRowAtIndexPath:self.r3s0 expectedSegueId:@"selectedYeast"];

  XCTAssertThrows([self doTestSelectRowAtIndexPath:self.r4s0 expectedSegueId:@"n/a"]);
}

- (void)doTestSelectRowAtIndexPath:(NSIndexPath *)indexPath expectedSegueId:(NSString *)segueId
{
  [self loadView];

  id vcMock = [OCMockObject partialMockForObject:self.vc];

  // TODO: uncomment this when this bug is fixed in OCMock (I filed it)
  // Alternatively delete it if the bug never gets fixed
  // https://github.com/erikdoe/ocmock/issues/214
//  id viewMock = [OCMockObject partialMockForObject:self.vc.view];

  @try {
    [[vcMock expect] performSegueWithIdentifier:segueId sender:self.vc];
//    [[viewMock expect] endEditing:OCMOCK_VALUE(YES)];

    [self.vc tableView:self.vc.tableView didSelectRowAtIndexPath:indexPath];

    [vcMock verify];
//    [viewMock verify];
  } @finally {
    [vcMock stopMocking];
//    [viewMock stopMocking];
  }
}

- (void)testCollectionViewDidSelectItemAtIndexPath
{
  [self loadView];

  OBTextStatisticsCollectionViewCell *textCell = [[OBTextStatisticsCollectionViewCell alloc] initWithFrame:CGRectZero];
  OBColorStatisticsCollectionViewCell *colorCell = [[OBColorStatisticsCollectionViewCell alloc] initWithFrame:CGRectZero];

  [self doTestCollectionViewDidSelectItemAtIndexPathWithCell:textCell];
  [self doTestCollectionViewDidSelectItemAtIndexPathWithCell:colorCell];
}

- (void)doTestCollectionViewDidSelectItemAtIndexPathWithCell:(id)cell
{

  self.vc.hasTriedTapping = NO;

  id mock = [OCMockObject partialMockForObject:self.vc.collectionView];
  [[[mock stub] andReturn:cell] cellForItemAtIndexPath:self.r0s0];

  [self.vc collectionView:self.vc.collectionView didSelectItemAtIndexPath:self.r0s0];

  XCTAssertTrue(self.vc.hasTriedTapping);
  [mock verify];
  [mock stopMocking];

  // Do it over agin to make sure that we skipped logging statistics this time
  mock = [OCMockObject partialMockForObject:self.vc.collectionView];
  [[mock expect] cellForItemAtIndexPath:OCMOCK_ANY];

  [self.vc collectionView:self.vc.collectionView didSelectItemAtIndexPath:self.r0s0];
  XCTAssertThrows([mock verify]);

  [mock stopMocking];
}

@end
