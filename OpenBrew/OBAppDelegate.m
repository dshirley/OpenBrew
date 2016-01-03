//
//  OBAppDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/10/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBAppDelegate.h"
#import "OBMalt.h"
#import "OBHops.h"
#import "OBSettings.h"
#import "Crittercism.h"
#import "Crittercism+NSErrorLogging.h"
#import "GAI.h"
#import "OBTableOfContentsViewController.h"
#import "OBCoreData.h"
#import "OBDataLoader.h"

// These header files are generated from encrypted headers stored in BuildScripts/ApiKeys
#import "CrittercismApiKey.h"
#import "GoogleAnalyticsApiKey.h"

@implementation OBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self initializeCrittercism];
  [self initializeGoogleAnalytics];

  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OpenBrew.sqlite"];
  NSError *error = nil;

  self.managedObjectContext = createManagedObjectContext(storeURL, nil, &error);
  if (error) {
    CRITTERCISM_LOG_ERROR(error);
    // TODO: This is a super bad error. Something should be displayed to the user
  }

  OBSettings *settings = [OBSettings settingsForContext:self.managedObjectContext];

  NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
  if (settings && ![settings.copiedStarterDataVersion isEqualToString:currentVersion]) {
    OBDataLoader *dataLoader = [[OBDataLoader alloc] initWithContext:self.managedObjectContext];

    if ([dataLoader loadIngredients]) {
      settings.copiedStarterDataVersion = currentVersion;
    } // TODO: else handle error with a good message

    if (![settings.hasCopiedSampleRecipes boolValue]) {
      [dataLoader loadSampleRecipes];
      settings.hasCopiedSampleRecipes = @(YES);
    }
  }

  [self.managedObjectContext save:nil];

  UINavigationController *nav = (UINavigationController *)[[self window] rootViewController];
  OBTableOfContentsViewController *firstVc = (OBTableOfContentsViewController *)nav.topViewController;
  NSAssert(firstVc.class == OBTableOfContentsViewController.class,
           @"Unexpected view controller: %@", firstVc.class);

  firstVc.managedObjectContext = self.managedObjectContext;
  firstVc.settings = settings;
  
  return YES;
}

- (void)initializeCrittercism
{
#ifndef DEBUG
#ifdef CRITTERCISM_API_KEY
  [Crittercism enableWithAppID:CRITTERCISM_API_KEY];
#endif
#endif
}

- (void)initializeGoogleAnalytics
{
#ifndef DEBUG
#ifdef GOOGLE_ANALYTICS_API_KEY
  // Optional: automatically send uncaught exceptions to Google Analytics.
  [GAI sharedInstance].trackUncaughtExceptions = NO;

  // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
  [GAI sharedInstance].dispatchInterval = 20;

  // Initialize tracker. Replace with your tracking ID.
  [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_API_KEY];
#endif
#endif
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  [self saveContext];
}

- (void)saveContext
{
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      // Replace this implementation with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    }
  }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
