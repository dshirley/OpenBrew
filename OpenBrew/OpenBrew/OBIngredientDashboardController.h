//
//  OBMaltViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRecipe.h"

typedef NS_ENUM(NSInteger, OBIngredientDashboardSkin) {
  OBMaltSkin,
  OBHopsSkin
};

// This delegate handles all the guts of OBIngredientDashboardController.
@protocol OBDashboardDelegate
- (NSString *)addButtonText;
- (NSString *)gaugeValueText;
- (NSString *)gaugeDescriptionText;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (void)populateCell:(UITableViewCell *)cell forIndex:(NSIndexPath *)index;

@end

// Just a wrapper class for the delegate.  This allows changing the implementation
// at runtime.
@interface OBIngredientDashboardController : UIViewController <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *gaugeValue;
@property (weak, nonatomic) IBOutlet UILabel *gaugeDescription;
@property (weak, nonatomic) IBOutlet UITableView *ingredientTable;

@property (strong, nonatomic) id <OBDashboardDelegate> delegate;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface OBMaltDashboardDelegate : NSObject  <OBDashboardDelegate>
@property (strong, nonatomic) OBRecipe *recipe;

- (id)initWithRecipe:(OBRecipe *)recipe;
@end

@interface OBHopsDashboardDelegate : NSObject  <OBDashboardDelegate>
@property (strong, nonatomic) OBRecipe *recipe;

- (id)initWithRecipe:(OBRecipe *)recipe;
@end