//
//  OBBrewery.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBBrewery.h"
#import "OBRecipe.h"
#import "OBMalt.h"
#import "OBHops.h"
#import "OBYeast.h"
#import "Crittercism+NSErrorLogging.h"

@implementation OBBrewery

@dynamic copiedStarterDataVersion;
@dynamic mashEfficiency;
@dynamic defaultBatchSize;
@dynamic hopAdditionDisplayMetric;
@dynamic hopGaugeDisplayMetric;
@dynamic maltAdditionDisplayMetric;
@dynamic maltGaugeDisplayMetric;
@dynamic selectedYeastManufacturer;

+ (OBBrewery *)breweryFromContext:(NSManagedObjectContext *)moc
{
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"Brewery"
                                            inManagedObjectContext:moc];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSError *error = nil;
  NSArray *array = [moc executeFetchRequest:request error:&error];

  OBBrewery *brewery = nil;
  if (!error && array && array.count > 0) {
    if (array.count > 1) {
      NSError *error = [NSError errorWithDomain:@"OBBrewery"
                                           code:1000
                                       userInfo:@{ @"count" : @(array.count)}];

      CRITTERCISM_LOG_ERROR(error);
    }

    brewery = array[0];
  } else {
    brewery = [NSEntityDescription insertNewObjectForEntityForName:@"Brewery"
                                            inManagedObjectContext:moc];
  }

  return brewery;
}


@end
