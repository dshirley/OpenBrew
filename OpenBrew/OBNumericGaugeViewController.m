//
//  OBGaugeViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/16/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBNumericGaugeViewController.h"
#import "OBColorView.h"
#import "Crittercism+NSErrorLogging.h"
#import "OBKvoUtils.h"

@interface OBNumericGaugeViewController()
@property (nonatomic) IBOutlet UICountingLabel *valueLabel;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation OBNumericGaugeViewController

- (instancetype)initWithTarget:(id)target
                  keyToDisplay:(NSString *)key
                   valueFormat:(NSString *)valueFormat
               descriptionText:(NSString *)descriptionText
{
  self = [super initWithNibName:@"OBNumericGaugeViewController" bundle:[NSBundle mainBundle]];

  if (self) {
    self.key = key;
    self.target = target;
    self.valueFormat = valueFormat;
    self.descriptionText = descriptionText;
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self refresh:NO];
}

- (void)refresh:(BOOL)animate;
{
  float startValue = self.valueLabel.currentValue;
  float endValue = [[self.target valueForKey:self.key] floatValue];

  self.descriptionLabel.text = self.descriptionText;

  NSTimeInterval duration = animate ? 0.25 : 0;

  self.valueLabel.method = UILabelCountingMethodEaseOut;
  self.valueLabel.format = self.valueFormat;

  [self.valueLabel countFrom:startValue to:endValue withDuration:duration];
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
