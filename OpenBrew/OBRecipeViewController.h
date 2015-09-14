//
//  OBRecipeViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSettings.h"
#import "GAITrackedViewController.h"

@interface OBRecipeViewController : GAITrackedViewController <UITableViewDataSource>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSManagedObjectContext *moc;
@property (nonatomic, readonly, assign) BOOL firstInteractionComplete;
@property (nonatomic, readonly, assign) CFAbsoluteTime loadTime;

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)switchToEmptyTableViewMode;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
