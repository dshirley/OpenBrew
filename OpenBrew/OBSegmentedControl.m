//
//  OBSegmentedControl.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/28/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBSegmentedControl.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@implementation OBSegmentedControl

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];

  if (self) {
    [self doInit];
  }

  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];

  if (self) {
    [self doInit];
  }

  return self;
}

- (instancetype)initWithItems:(NSArray *)items
{
  self = [super initWithItems:items];

  if (self) {
    [self doInit];
  }

  return self;
}

- (void)doInit
{
  [self addTarget:self action:@selector(segmentSelected) forControlEvents:UIControlEventValueChanged];
}

- (void)segmentSelected
{
  id<OBSegmentedControlDelegate> delegate = self.delegate;

  [delegate segmentedControl:self segmentSelected:self.selectedSegmentIndex];

  NSString *title = [delegate segmentTitlesForSegmentedControl:self][self.selectedSegmentIndex];
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:self.gaCategory
                                                        action:NSStringFromClass(delegate.class)
                                                         label:title
                                                         value:nil] build]];
}

- (void)setDelegate:(id<OBSegmentedControlDelegate>)delegate
{
  _delegate = delegate;

  [self removeAllSegments];

  NSArray *titles = [delegate segmentTitlesForSegmentedControl:self];
  for (NSInteger i = 0; i < titles.count; i++) {
    [self insertSegmentWithTitle:titles[i]
                         atIndex:i
                        animated:NO];
  }

  NSInteger index = [delegate initiallySelectedSegmentForSegmentedControl:self];
  [self setSelectedSegmentIndex:index];
}

@end
