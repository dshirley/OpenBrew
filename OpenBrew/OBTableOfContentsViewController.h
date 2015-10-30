//
//  OBCalculationsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/17/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "OBSettings.h"

@interface OBTableOfContentsViewController : GAITrackedViewController <UITableViewDataSource>

@property (nonatomic) OBSettings *settings;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView;

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView
         cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;

//- (void)tableView:(nonnull UITableView *)tableView
//commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//forRowAtIndexPath:(nonnull NSIndexPath *)indexPath;

- (nullable NSString *)tableView:(nonnull UITableView *)tableView
         titleForHeaderInSection:(NSInteger)section;

@end
