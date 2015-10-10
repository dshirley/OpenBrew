//
//  OBAbvCalculationsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBAbvCalculationsViewController.h"
#import "OBPickerDelegate.h"
#import "OBKvoUtils.h"

@interface OBAbvCalculationsViewController ()
@property (nonatomic) OBPickerDelegate *startingGravityPickerDelegate;
@property (nonatomic) OBPickerDelegate *finishingGravityPickerDelegate;

@property (nonatomic) NSNumber *startingGravity;
@property (nonatomic) NSNumber *finishingGravity;
@end

@implementation OBAbvCalculationsViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.startingGravity = @(1.050);
  self.finishingGravity = @(1.010);

  [self addObserver:self forKeyPath:KVO_KEY(startingGravity) options:0 context:nil];
  [self addObserver:self forKeyPath:KVO_KEY(finishingGravity) options:0 context:nil];

  self.startingGravityPickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(startingGravity)];
  [self.startingGravityPickerDelegate from:1.000 to:1.500 incrementBy:0.001];
  self.startingGravityPicker.delegate = self.startingGravityPickerDelegate;

  self.finishingGravityPickerDelegate = [[OBPickerDelegate alloc] initWithTarget:self key:KVO_KEY(finishingGravity)];
  [self.finishingGravityPickerDelegate from:1.000 to:1.500 incrementBy:0.001];
  self.finishingGravityPicker.delegate = self.finishingGravityPickerDelegate;
}

- (void)dealloc
{
  [self removeObserver:self forKeyPath:KVO_KEY(startingGravity)];
  [self removeObserver:self forKeyPath:KVO_KEY(finishingGravity)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
  // TODO: update gauge
}


@end
