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

@interface OBDrawerTableViewController : UIViewController

@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
@property (nonatomic, retain) OBRecipe *recipe;

- (NSArray *)ingredientData;

- (id)ingredientForDrawer;

- (UITableViewCell *)drawerCell;

- (void)reload;

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData;

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData;

- (void)removeIngredient:(id)ingredient fromRecipe:(OBRecipe *)recipe;

- (void)finishDisplayingDrawerCell:(UITableViewCell *)cell;

- (id)ingredientAtIndexPath:(NSIndexPath *)indexPath;

@end
