//
//  OBColorGaugeViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/10/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBColorGaugeViewController.h"
#import "OBColorView.h"

@interface OBColorGaugeViewController ()
@property (nonatomic) IBOutlet OBColorView *colorView;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation OBColorGaugeViewController

- (instancetype)initWithTarget:(id)target
                  keyToDisplay:(NSString *)key
{
  self = [super initWithNibName:@"OBColorGaugeViewController" bundle:[NSBundle mainBundle]];

  if (self) {
    self.key = key;
    self.target = target;
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self refresh:NO];
}

// TODO: add animation
- (void)refresh:(BOOL)animate;
{
  float colorInSrm = [[self.target valueForKey:self.key] floatValue];
  self.colorView.colorInSrm = colorInSrm;
  self.descriptionLabel.text = [NSString stringWithFormat:@"%ld SRM", (long)colorInSrm];
}

- (void)dealloc
{
  self.target = nil;
}

- (void)setTarget:(id)target
{
  [_target removeObserver:self forKeyPath:self.key];

  _target = target;

  [_target addObserver:self forKeyPath:self.key options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  [self refresh:YES];
}

@end
