//
//  OBRecipeViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBBrewery.h"

@interface OBRecipeViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, strong) OBBrewery *brewery;

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
