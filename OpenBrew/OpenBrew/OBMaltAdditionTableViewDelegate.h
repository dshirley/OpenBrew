//
//  OBMaltAdditionTableViewDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"
#import "OBPickerObserver.h"

@interface OBMaltAdditionTableViewDelegate : OBDrawerTableViewDelegate <OBPickerObserver>

- (id)initWithRecipe:(OBRecipe *)recipe andTableView:(UITableView *)tableView;

@end
