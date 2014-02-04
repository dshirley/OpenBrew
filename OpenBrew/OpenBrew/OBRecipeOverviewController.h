//
//  OBRecipeOverviewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/26/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRecipe.h"

@interface OBRecipeOverviewController : UITableViewController

@property (nonatomic, strong) OBRecipe *recipe;

@property (nonatomic, weak) IBOutlet UILabel *batchSizeLabel;
@property (nonatomic, weak) IBOutlet UILabel *styleLabel;
@property (nonatomic, weak) IBOutlet UILabel *yeastLabel;
@property (nonatomic, weak) IBOutlet UILabel *originalGravityLabel;
@property (nonatomic, weak) IBOutlet UILabel *finalGravityLabel;
@property (nonatomic, weak) IBOutlet UILabel *abvLabel;
@property (nonatomic, weak) IBOutlet UILabel *colorLabel;
@property (nonatomic, weak) IBOutlet UILabel *ibuLabel;

- (void)reloadData;

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender;

@end
