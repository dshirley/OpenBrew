//
//  OBMaltViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRecipe.h"
#import "OBIngredientGauge.h"

// Just a wrapper class for the delegate.  This allows changing the implementation
// at runtime.
@interface OBMaltAdditionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet OBIngredientGauge *gauge;
@property (weak, nonatomic) IBOutlet UITableView *ingredientTable;
@property (strong, nonatomic) OBRecipe *recipe;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

- (IBAction)ingredientSelected:(UIStoryboardSegue *)unwindSegue;

@end
