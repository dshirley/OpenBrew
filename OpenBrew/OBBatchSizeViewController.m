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

// Google Analytics constants
static NSString* const OBGAScreenName = @"Batch Size Screen";

@interface OBBatchSizeViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) OBBatchSizeTableViewDelegate *tableViewDelegate;
@end

@implementation OBBatchSizeViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.screenName = OBGAScreenName;

  self.tableViewDelegate = [[OBBatchSizeTableViewDelegate alloc] initWithRecipe:self.recipe
                                                                   andTableView:self.tableView
                                                                  andGACategory:OBGAScreenName];

  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  [self.tableView reloadData];
}

- (void)setRecipe:(OBRecipe *)recipe
{
  [_recipe removeObserver:self forKeyPath:KVO_KEY(postBoilVolumeInGallons)];
  [_recipe removeObserver:self forKeyPath:KVO_KEY(preBoilVolumeInGallons)];

  _recipe = recipe;

  [_recipe addObserver:self forKeyPath:KVO_KEY(postBoilVolumeInGallons) options:0 context:nil];
  [_recipe addObserver:self forKeyPath:KVO_KEY(preBoilVolumeInGallons) options:0 context:nil];

}

- (void)dealloc
{
  self.recipe = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  [self.tableView reloadData];
}

@end
