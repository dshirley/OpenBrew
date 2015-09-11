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

@property (nonatomic) OBRecipe *recipe;

// Subviews are made visible for the purpose of unit testing
@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) IBOutlet UITextField *recipeNameTextField;

// We log tabs to google analytics when the user taps on the collection view cell
// The idea is that it will give us feedback on whether or not the user things
// the clicking on the statistics should do something.  This variable prevents
// us from logging a bunch of google analytics events (we only log one tap
// once the view controller is loaded)
@property (nonatomic, assign) BOOL hasTriedTapping;

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

#pragma mark UICollectionViewDelegate methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end
