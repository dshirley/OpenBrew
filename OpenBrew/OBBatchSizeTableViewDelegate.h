//
//  OBBatchSizeTableViewDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 6/8/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"

@interface OBBatchSizeTableViewDelegate : OBDrawerTableViewDelegate

@property (nonatomic, readonly) OBRecipe *recipe;
@property (nonatomic, readonly) UITableView *tableView;

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView andGACategory:(NSString *)gaCategory;

#pragma mark OBDrawerTableViewDelegate Methods

- (NSArray *)ingredientData;

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData;

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData;

#pragma mark UITableViewDataSource methods

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

#pragma mark UITableViewDelegate override methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

@end
