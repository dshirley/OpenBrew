//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltViewController.h"

@interface OBMaltViewController ()

@end

@implementation OBMaltViewController
@synthesize maltAdditions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  NSLog(@"shite");
    if (self) {
      
        // Custom initialization
    }
    return self;
}

- (void)loadView {
  [super loadView];
  
  UITableView *table = [self maltAdditions];
  [table setDelegate:self];
  [table reloadData];
  NSLog(@"fuuke");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  UITableView *table = [self maltAdditions];
    [table reloadData];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OBMaltCell"
                                                          forIndexPath:indexPath];
  
  [[cell textLabel] setText:[NSString stringWithFormat:@"test%d", [indexPath row]]];
  [[cell detailTextLabel] setText:@"1.050"];
  
  return cell;
}

@end
