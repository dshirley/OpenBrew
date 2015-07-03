//
//  OBDrawerTableViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/6/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBIngredientGauge;
@class OBRecipe;
@protocol OBIngredientAddition;

@interface OBDrawerTableViewDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSIndexPath *drawerIndexPath;

// This is used for tracking delete and move events & potentially more if subclasses
// do something with it.
@property (nonatomic, strong) NSString *gaCategory;

- (id)initWithGACategory:(NSString *)gaCategory;

#pragma mark Template Methods

- (NSArray *)ingredientData;

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData;

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData;

#pragma mark Utility Methods

// FIXME: some of these might not be needed externally anymore

- (id)ingredientForDrawer;

- (UITableViewCell *)cellBeforeDrawerForTableView:(UITableView *)tableView;

- (id<OBIngredientAddition>)ingredientAtIndexPath:(NSIndexPath *)indexPath;

@end
