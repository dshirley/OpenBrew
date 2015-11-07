//
//  OBMainViewControllerTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/17/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTableOfContentsViewController.h"
#import "OBBaseTestCase.h"
#import "OBRecipeListViewController.h"
#import <OCMock/OCMock.h>

@interface OBTableOfContentsViewControllerTest : OBBaseTestCase
@property (nonatomic) OBTableOfContentsViewController *vc;
@end

@implementation OBTableOfContentsViewControllerTest

- (void)setUp {
  [super setUp];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  self.vc = [storyboard instantiateViewControllerWithIdentifier:@"tableOfContents"];
  self.vc.settings = self.settings;
  self.vc.managedObjectContext = self.ctx;
}

- (void)testViewDidLoad
{
  (void)self.vc.view;

  XCTAssertEqualObjects(@"Table of contents", self.vc.screenName);

  XCTAssertNotNil(self.vc.tableView);
  XCTAssertEqual(self.vc, self.vc.tableView.dataSource);
  XCTAssertEqual(self.vc, self.vc.tableView.delegate);
}

- (void)testPrepareForSegue_showRecipeList
{
  OBRecipeListViewController *dest = [[OBRecipeListViewController alloc] init];
  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"showRecipeList"
                                                                    source:self.vc
                                                               destination:dest];

  [self.vc prepareForSegue:segue sender:[NSNull null]];
  XCTAssertEqual(self.ctx, dest.managedObjectContext);
  XCTAssertEqual(self.settings, dest.settings);
}

- (void)testPrepareForSegue_invalid
{
  UIStoryboardSegue *segue = [[UIStoryboardSegue alloc] initWithIdentifier:@"badSegue"
                                                                    source:self.vc
                                                               destination:self.vc];

  XCTAssertThrows([self.vc prepareForSegue:segue sender:[NSNull null]]);
}

@end
