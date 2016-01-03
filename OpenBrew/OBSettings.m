//
//  OBSettings.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBSettings.h"
#import "Crittercism+NSErrorLogging.h"

@implementation OBSettings

@dynamic copiedStarterDataVersion;
@dynamic defaultMashEfficiency;
@dynamic defaultPostBoilSize;
@dynamic defaultPreBoilSize;
@dynamic hasCopiedSampleRecipes;
@dynamic hopQuantityUnits;
@dynamic hopAdditionDisplayMetric;
@dynamic hopGaugeDisplayMetric;
@dynamic maltAdditionDisplayMetric;
@dynamic maltGaugeDisplayMetric;
@dynamic selectedYeastManufacturer;
@dynamic ibuFormula;

+ (OBSettings *)settingsForContext:(NSManagedObjectContext *)moc
{
  if (!moc) {
    return nil;
  }
  
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Settings"];

  NSError *error = nil;
  NSArray *array = [moc executeFetchRequest:request error:&error];

  OBSettings *settings = nil;
  if (!error && array && array.count > 0) {
    if (array.count > 1) {
      NSError *error = [NSError errorWithDomain:@"OBSettings"
                                           code:1000
                                       userInfo:@{ @"count" : @(array.count)}];

      CRITTERCISM_LOG_ERROR(error);
    }

    settings = array[0];
  } else {
    settings = [NSEntityDescription insertNewObjectForEntityForName:@"Settings"
                                             inManagedObjectContext:moc];
  }

  return settings;
}

@end
