//
//  OBRecipeOverviewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/26/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRecipe.h"
#import "GAITrackedViewController.h"

@interface OBRecipeOverviewController : GAITrackedViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) OBRecipe *recipe;

// Subviews are made visible for the purpose of unit testing
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UITextField *recipeNameTextField;

- (void)reloadData;

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
