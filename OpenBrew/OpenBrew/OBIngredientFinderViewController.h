//
//  OBIngredientFinderViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBIngredientFinderViewController : UITableViewController <UITableViewDataSource>

@property (strong, nonatomic) id selectedIngredient;

- (void)setIngredients:(NSArray *)ingredients;

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section;

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section;

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index;

@end
