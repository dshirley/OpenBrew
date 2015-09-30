//
//  OBSettingsSegmentedControlDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/29/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBSettingsSegmentedControlDelegate.h"

@interface OBSettingsSegmentedControlDelegate()
@property (nonatomic) OBSettings *settings;
@end

@implementation OBSettingsSegmentedControlDelegate

- (instancetype)initWithSettings:(OBSettings *)settings
{
  self = [super init];

  if (self) {
    self.settings = settings;
  }

  return self;
}

#pragma mark OBSegmentedControlDelegate methods

- (NSArray *)segmentTitlesForSegmentedControl:(UISegmentedControl *)segmentedControl
{
  return [self titles];
}

- (void)segmentedControl:(UISegmentedControl *)segmentedControl segmentSelected:(NSInteger)index
{
  [self.settings setValue:self.values[index] forKey:self.settingsKey];
}

- (NSInteger)initiallySelectedSegmentForSegmentedControl:(UISegmentedControl *)segmentedControl
{
  id value = [self.settings valueForKey:self.settingsKey];
  NSInteger index = [self.values indexOfObject:value];
  NSAssert(index != NSNotFound, @"'%@' not found in '%@'", value, self.values);
  return index;
}

#pragma mark Template methods - THESE MUST BE OVERRIDDEN

- (NSArray *)titles
{
  [NSException raise:@"Unimplemented" format:@"The 'titles' method must be overriden"];
    return nil;
}

- (NSArray *)values
{
  [NSException raise:@"Unimplemented" format:@"The 'values' method must be overriden"];
    return nil;
}

- (NSString *)settingsKey
{
  [NSException raise:@"Unimplemented" format:@"The 'settingsKey' method must be overriden"];
  return nil;
}

@end
