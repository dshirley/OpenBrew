//
//  OBRecipeListViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBSettings.h"
#import "GAITrackedViewController.h"
#import "OBPlaceholderView.h"

@interface OBRecipeListViewController : GAITrackedViewController <UITableViewDelegate>

@property (nonatomic) OBSettings *settings;

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet OBPlaceholderView *placeholderView;

@property (nonatomic) NSManagedObjectContext *moc;
@property (nonatomic, readonly, assign) BOOL firstInteractionComplete;
@property (nonatomic, readonly, assign) CFAbsoluteTime loadTime;

- (void)switchToEmptyTableViewMode;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
