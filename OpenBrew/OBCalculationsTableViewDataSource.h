//
//  OBCalculationsTableViewDataSource.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/27/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBCalculationsTableViewDataSource : NSObject <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// Returns the view controller that should be transitioned to when the cell at the index path is selected
- (UIViewController *)viewControllerForIndexPath:(NSIndexPath *)indexPath;

@end
