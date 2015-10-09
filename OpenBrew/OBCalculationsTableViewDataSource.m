//
//  OBCalculationsTableViewDataSource.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/27/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBCalculationsTableViewDataSource.h"
#import "OBMashCalculationsViewController.h"

@interface OBCalculationsTableViewDataSource()
@property (nonatomic) NSMutableArray *calculations;
@property (nonatomic) NSMutableDictionary *cellTextToStoryboardIdMapping;
@end

@implementation OBCalculationsTableViewDataSource

- (instancetype)init
{
  self = [super init];

  if (self) {
    [self addCellText:@"Strike temperature" mappingToStoryboardId:@"mash calculations"];
  }

  return self;
}

- (void)addCellText:(NSString *)cellText mappingToStoryboardId:(NSString *)storyboardId
{
  if (!self.calculations) {
    self.calculations = [NSMutableArray array];
  }

  if (!self.cellTextToStoryboardIdMapping) {
    self.cellTextToStoryboardIdMapping = [NSMutableDictionary dictionary];
  }

  [self.calculations addObject:cellText];
  self.cellTextToStoryboardIdMapping[cellText] = storyboardId;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.calculations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"calculationCell"];
  cell.textLabel.text = self.calculations[indexPath.row];
  return cell;
}

- (UIViewController *)viewControllerForIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellText = self.calculations[indexPath.row];
  NSString *storyboardId = self.cellTextToStoryboardIdMapping[cellText];
  UIStoryboard *calculationsStoryboard = [UIStoryboard storyboardWithName:@"Calculations" bundle:nil];

  return [calculationsStoryboard instantiateViewControllerWithIdentifier:storyboardId];
}

@end
