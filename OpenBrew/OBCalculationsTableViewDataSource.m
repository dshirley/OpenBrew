//
//  OBCalculationsTableViewDataSource.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/27/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBCalculationsTableViewDataSource.h"
#import "OBMashCalculationsViewController.h"

@interface OBCellInfo : NSObject
@property (nonatomic) NSString *text;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *mappingToStoryboardId;

- (instancetype)initWithText:(NSString *)text image:(NSString *)imageName storyboardId:(NSString *)mappingToStoryboardId;

@end

@implementation OBCellInfo

- (instancetype)initWithText:(NSString *)text image:(NSString *)imageName storyboardId:(NSString *)mappingToStoryboardId
{
  self = [super init];

  if (self) {
    self.text = text;
    self.image = [UIImage imageNamed:imageName];
    self.mappingToStoryboardId = mappingToStoryboardId;
  }

  return self;
}

@end

@interface OBCalculationsTableViewDataSource()
@property (nonatomic) NSArray *sections;
@property (nonatomic) NSArray *cells;
@end

@implementation OBCalculationsTableViewDataSource

- (instancetype)init
{
  self = [super init];

  if (self) {
    self.sections = @[ @"Mash",
                       @"Fermentation",
                       @"Carbonation"
                       ];

    self.cells = @[
                   @[ // Mash section
                     [[OBCellInfo alloc] initWithText:@"Strike temperature"
                                                image:@"StrikeWater"
                                         storyboardId:@"mash calculations"] ],
                   @[ // Fermentaiton section
                     [[OBCellInfo alloc] initWithText:@"Alcohol & attenuation"
                                                image:@"StrikeWater"
                                         storyboardId:@"abv calculations"] ],
                   @[ // Carbonation section
                     [[OBCellInfo alloc] initWithText:@"Kegging"
                                                image:@"Regulator"
                                         storyboardId:@"carbonation calculations"],
                     [[OBCellInfo alloc] initWithText:@"Bottling"
                                                image:@"Bottle"
                                         storyboardId:@"bottling calculations"]
                     ]
                   ];

  }

  return self;
}

- (OBCellInfo *)cellInfoForIndexPath:(NSIndexPath *)indexPath
{
  return self.cells[indexPath.section][indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.sections.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return self.sections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.cells[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"calculationCell"];
  OBCellInfo *cellInfo = [self cellInfoForIndexPath:indexPath];

  cell.textLabel.text = cellInfo.text;
  cell.imageView.image = cellInfo.image;

  return cell;
}

- (UIViewController *)viewControllerForIndexPath:(NSIndexPath *)indexPath
{
  OBCellInfo *cellInfo = [self cellInfoForIndexPath:indexPath];

  UIStoryboard *calculationsStoryboard = [UIStoryboard storyboardWithName:@"Calculations"
                                                                   bundle:[NSBundle mainBundle]];

  return [calculationsStoryboard instantiateViewControllerWithIdentifier:cellInfo.mappingToStoryboardId];
}

@end
