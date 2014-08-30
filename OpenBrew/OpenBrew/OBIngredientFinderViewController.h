//
//  OBIngredientFinderViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBIngredientFinderViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) id selectedIngredient;

- (void)setIngredients:(NSArray *)ingredients;

@end
