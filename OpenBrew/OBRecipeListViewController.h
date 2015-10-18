//
//  OBRecipeListViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/17/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBPlaceholderView.h"
#import "GAITrackedViewController.h"
#import "OBSettings.h"

@interface OBRecipeListViewController : GAITrackedViewController <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet OBPlaceholderView *placeholderView;

@property (nonatomic) OBSettings *settings;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
