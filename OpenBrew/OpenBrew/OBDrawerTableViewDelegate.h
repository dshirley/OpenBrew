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

@interface OBDrawerTableViewDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSIndexPath *drawerIndexPath;

- (id)init;

#pragma mark Template Methods

- (NSArray *)ingredientData;

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData;

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData;

- (void)removeIngredient:(id)ingredient fromRecipe:(OBRecipe *)recipe;

- (void)finishDisplayingDrawerCell:(UITableViewCell *)cell;

#pragma mark Utility Methods

- (void)closeDrawerForTableView:(UITableView *)tableView;

- (id)ingredientForDrawer;

- (UITableViewCell *)cellBeforeDrawerForTableView:(UITableView *)tableView;
- (UITableViewCell *)drawerCellForTableView:(UITableView *)tableView;

- (id)ingredientAtIndexPath:(NSIndexPath *)indexPath;

@end
