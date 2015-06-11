//
//  OBBatchSizeTableViewDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 6/8/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"
#import "OBPickerObserver.h"

@interface OBBatchSizeTableViewDelegate : OBDrawerTableViewDelegate <OBPickerObserver>

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView;

- (void)pickerChanged;

@end
