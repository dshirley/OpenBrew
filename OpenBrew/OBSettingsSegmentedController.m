//
//  OBSettingsSegmentedController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/31/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBSettingsSegmentedController.h"
#import "OBBrewery.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface OBSettingsSegmentedController()
@property (nonatomic, weak) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) OBBrewery *brewery;
@property (nonatomic, strong) NSString *settingKey;
@property (nonatomic, strong) NSMutableArray *valueMapping;
@end

@implementation OBSettingsSegmentedController


- (id)initWithSegmentedControl:(UISegmentedControl *)segmentedControl
                       brewery:(OBBrewery *)brewery
                    settingKey:(NSString *)brewerySettingKey;
{
  self = [super init];

  if (self) {
    self.brewery = brewery;
    self.segmentedControl = segmentedControl;
    self.settingKey = brewerySettingKey;
    self.valueMapping = [NSMutableArray array];

    [self.segmentedControl removeAllSegments];
    [self.segmentedControl addTarget:self
                              action:@selector(segmentChanged:)
                    forControlEvents:UIControlEventValueChanged];
  }

  return self;
}

- (void)addSegment:(NSString *)text setsValue:(id)value;
{
  [self.valueMapping addObject:value];
  [self.segmentedControl insertSegmentWithTitle:text
                                        atIndex:self.segmentedControl.numberOfSegments
                                       animated:NO];
}

- (void)updateSelectedSegment
{
  if (self.valueMapping.count == 0) {
    // TODO: log an error
    return;
  }

  id value = [self.brewery valueForKey:self.settingKey];
  NSInteger index = [self.valueMapping indexOfObject:value];

  if (index == NSNotFound) {
    // Things somehow got off.  Lets recover from it, though.
    // TODO: add some error logging here?
    index = 0;
    value = self.valueMapping[0];
    [self.brewery setValue:value forKey:self.settingKey];
  }

  [self.segmentedControl setSelectedSegmentIndex:index];
}

- (void)segmentChanged:(UISegmentedControl *)sender
{
  NSInteger index = sender.selectedSegmentIndex;
  id value = self.valueMapping[index];
  
  [self.brewery setValue:value forKey:self.settingKey];

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Brewery Settings"
                                                        action:self.settingKey
                                                         label:[value description]
                                                         value:nil] build]];
}


@end
