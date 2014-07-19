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
@interface OBIngredientDashboardController : UIViewController <UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet OBIngredientGauge *gauge;
@property (weak, nonatomic) IBOutlet UITableView *ingredientTable;
@property (strong, nonatomic) OBRecipe *recipe;

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

- (IBAction)ingredientSelected:(UIStoryboardSegue *)unwindSegue;

#pragma UIPickerViewDataSource Methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

#pragma UIPickerViewDelegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component;

@end
