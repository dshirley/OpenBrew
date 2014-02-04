//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientDashboardController.h"

@interface OBIngredientDashboardController ()
- (void)reload;
@end

@implementation OBIngredientDashboardController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
      
        // Custom initialization
    }
    return self;
}

- (void)loadView {
  [super loadView];
  [self reload];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self reload];
}

- (void)reload {
  [[self ingredientTable] reloadData];
  [[self gaugeValue] setText:[[self delegate] gaugeValueText]];
  [[self gaugeDescription] setText:[[self delegate] gaugeDescriptionText]];
  [[self addButton] setTitle:[[self delegate] addButtonText]
                    forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[self delegate] tableView:tableView
                        numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView
                           dequeueReusableCellWithIdentifier:@"OBIngredientAddition"
                           forIndexPath:indexPath];
  
  [[self delegate] populateCell:cell forIndex:indexPath];
  
  return cell;
}

@end

@implementation OBMaltDashboardDelegate

- (id)initWithRecipe:(OBRecipe *)recipe {
  if (self) {
    [self setRecipe:recipe];
  }
  
  return self;
}

- (NSString *)addButtonText {
  return @"Add Malt";
}

- (NSString *)gaugeValueText {
  float gravity = [[self recipe] originalGravity];
  return [NSString stringWithFormat:@"%.2f", gravity];
}

- (NSString *)gaugeDescriptionText {
  return @"Estimated Starting Gravity";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}

- (void)populateCell:(UITableViewCell *)cell forIndex:(NSIndexPath *)index {
  [[cell textLabel] setText:@"Malt"];
  [[cell detailTextLabel] setText:@"1.053"];
}
@end


@implementation OBHopsDashboardDelegate

- (id)initWithRecipe:(OBRecipe *)recipe {
  if (self) {
    [self setRecipe:recipe];
  }
  
  return self;
}

- (NSString *)addButtonText {
  return @"Add Hops";
}

- (NSString *)gaugeValueText {
  float ibus = [[self recipe] IBUs];
  return [NSString stringWithFormat:@"%.0f", ibus];
}

- (NSString *)gaugeDescriptionText {
  return @"Estimated IBUs";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}

- (void)populateCell:(UITableViewCell *)cell forIndex:(NSIndexPath *)index {
  [[cell textLabel] setText:@"Hops"];
  [[cell detailTextLabel] setText:@"12"];
}


@end
