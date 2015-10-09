//
//  OBMashCalculationsViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/2/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "OBGaugeView.h"

@interface OBMashCalculationsViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet OBGaugeView *gaugeView;

#pragma mark User Input Fields

@property (nonatomic) NSString *grainWeight;
@property (nonatomic) NSString *grainTemperature;
@property (nonatomic) NSString *waterVolume;
@property (nonatomic) NSString *targetTemperature;

- (NSString *)inputForRow:(NSInteger)row;

- (float)valueForRow:(NSInteger)row;

#pragma mark UITableViewDataSourceMethods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark UITableViewDelegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
