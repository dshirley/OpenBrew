//
//  OBCalculationsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/17/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBTableOfContentsViewController.h"

@interface OBTableOfContentsViewController ()
@property (nonatomic) NSArray *sections;
@property (nonatomic) NSArray *cells;
@end

@implementation OBTableOfContentsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.screenName = @"Calculations List";

  self.sections = @[ @"Mash",
                     @"Fermentation",
                     @"Carbonation"
                     ];

  self.cells = @[
                 @[ // Mash section
                   @"strikeWater",
                   @"mashStep",
                   @"decoction" ],
                 @[ // Fermentaiton section
                   @"abv" ],
                 @[ // Carbonation section
                   @"kegging",
                   @"bottling"
                   ]
                 ];
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.sections.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView
         titleForHeaderInSection:(NSInteger)section
{
  return self.sections[section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  return [self.cells[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellId = self.cells[indexPath.section][indexPath.row];
  return [tableView dequeueReusableCellWithIdentifier:cellId];
}

@end




