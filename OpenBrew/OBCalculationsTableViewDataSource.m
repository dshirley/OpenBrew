//
//  OBCalculationsTableViewDataSource.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/27/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBCalculationsTableViewDataSource.h"

@interface OBCalculationsTableViewDataSource()
@property (nonatomic) NSArray *calculations;
@end

@implementation OBCalculationsTableViewDataSource

- (instancetype)init
{
  self = [super init];

  if (self) {
    self.calculations = @[ @[ @"Strike temperature" ] ];
  }

  return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.calculations[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"calculationCell"];
  cell.textLabel.text = self.calculations[indexPath.section][indexPath.row];
  return cell;
}

@end
