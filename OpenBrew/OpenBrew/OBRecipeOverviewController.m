//
//  OBRecipeOverviewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/26/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipeOverviewController.h"

@interface OBRecipeOverviewController ()

@end

@implementation OBRecipeOverviewController
@synthesize abvLabel;
@synthesize batchSizeLabel;
@synthesize colorLabel;
@synthesize finalGravityLabel;
@synthesize ibuLabel;
@synthesize originalGravityLabel;
@synthesize yeastLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)reloadData {

  NSString *abv = [NSString stringWithFormat:@"%.1f%%", [[self recipe] alcoholByVolume]];
  [[self abvLabel] setText:abv];

  NSString *batchSize = [NSString stringWithFormat:@"%.1f gallons",
                         [[self recipe] batchSizeInGallons]];
  
  [[self batchSizeLabel] setText:batchSize];
  
  // FIXME: need to have a color method in recipe
  [colorLabel setText:@"FIXME SRM"];
  
  NSString *fg = [NSString stringWithFormat:@"%.3f", [[self recipe] finalGravity]];
  [[self finalGravityLabel] setText:fg];

  // FIXME: Round instead of int()
  NSString *ibu = [NSString stringWithFormat:@"%d IBU", (int) [[self recipe] IBUs]];
  [[self ibuLabel] setText:ibu];

  NSString *og = [NSString stringWithFormat:@"%.3f", [[self recipe] originalGravity]];
  [[self originalGravityLabel] setText:og];

  NSString *yeast = [[[[self recipe] yeast] yeast] name];
  [[self yeastLabel] setText:yeast];
}

@end
