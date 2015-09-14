//
//  OBSettings.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBSettings.h"
#import "OBRecipe.h"
#import "OBMalt.h"
#import "OBHops.h"
#import "OBYeast.h"
#import "Crittercism+NSErrorLogging.h"

@implementation OBSettings

@dynamic copiedStarterDataVersion;
@dynamic mashEfficiency;
@dynamic defaultBatchSize;
@dynamic hopAdditionDisplayMetric;
@dynamic hopGaugeDisplayMetric;
@dynamic maltAdditionDisplayMetric;
@dynamic maltGaugeDisplayMetric;
@dynamic selectedYeastManufacturer;

+ (OBSettings *)settingsForContext:(NSManagedObjectContext *)moc;
{
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"Settings"
                                            inManagedObjectContext:moc];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

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
