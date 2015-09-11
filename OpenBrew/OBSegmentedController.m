//
//  OBSegmentedController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/31/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBSegmentedController.h"
#import "OBBrewery.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface OBSegmentedController()
@property (nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic) NSMutableArray *segmentActions;
@property (nonatomic) NSString *googleAnalyticsAction;
@end

@implementation OBSegmentedController


- (id)initWithSegmentedControl:(UISegmentedControl *)segmentedControl
         googleAnalyticsAction:(NSString *)action
{
  self = [super init];

  if (self) {
    self.segmentedControl = segmentedControl;
    self.googleAnalyticsAction = action;

    self.segmentActions = [NSMutableArray array];

    [self.segmentedControl removeAllSegments];
    [self.segmentedControl addTarget:self
                              action:@selector(segmentChanged:)
                    forControlEvents:UIControlEventValueChanged];
  }

  return self;
}

- (void)addSegment:(NSString *)text actionWhenSelected:(OBSegmentSelectedAction)action
{
  [self.segmentActions addObject:action];
  [self.segmentedControl insertSegmentWithTitle:text
                                        atIndex:self.segmentedControl.numberOfSegments
                                       animated:NO];
}

- (void)segmentChanged:(UISegmentedControl *)sender
{
  NSInteger index = sender.selectedSegmentIndex;
  OBSegmentSelectedAction action = self.segmentActions[index];

  action();

  NSString *title = [sender titleForSegmentAtIndex:index];
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Brewery Settings"
                                                        action:self.googleAnalyticsAction
                                                         label:title
                                                         value:nil] build]];
}

@end
