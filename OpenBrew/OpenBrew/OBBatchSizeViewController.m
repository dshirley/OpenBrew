//
//  OBBatchSizeViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/20/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBBatchSizeViewController.h"
#import "OBRecipe.h"
#import "OBIngredientGauge.h"
#import "OBBatchSizeTableViewDelegate.h"
#import "OBKvoUtils.h"
#import <math.h>

#define MAX_GALLONS 20
#define NUM_FRACTIONAL_GALLONS_PER_GALLON 4
#define NUM_ROWS_IN_PICKER (MAX_GALLONS * NUM_FRACTIONAL_GALLONS_PER_GALLON)

// Google Analytics constants
static NSString* const OBGAScreenName = @"Batch Size Screen";

@interface OBBatchSizeViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, strong) OBBatchSizeTableViewDelegate *tableViewDelegate;
@end

@implementation OBBatchSizeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)loadView {
  [super loadView];
  self.screenName = OBGAScreenName;
  
  self.tableViewDelegate = [[OBBatchSizeTableViewDelegate alloc] initWithRecipe:self.recipe
                                                                   andTableView:self.tableView
                                                                  andGACategory:OBGAScreenName];

  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  // TODO: Do we need a display settings view for this controller?
  // Eg. [self addMaltDisplaySettingsView];

  [self.tableView reloadData];
}

@end
