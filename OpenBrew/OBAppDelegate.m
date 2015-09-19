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
#import "OBRecipeListViewController.h"
#import "OBCoreData.h"

static NSString *const CRITTER_APP_ID_PRODUCTION = @"558d6dda9ccc10f6040881c2";
static NSString *const CRITTER_APP_ID_DEVELOPMENT = @"558d6dcb9ccc10f6040881c1";

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

  OBSettings *settings = [self settingsForContext:self.managedObjectContext];

  NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
  if (settings && ![settings.copiedStarterDataVersion isEqualToString:currentVersion]) {
    NSURL *startUpDbURL = [[NSBundle mainBundle] URLForResource:@"OpenBrewStartupData.sqlite"
                                                  withExtension:@""];

    NSDictionary *startupDbOptions = @{ NSReadOnlyPersistentStoreOption: @(true) };
    NSManagedObjectContext *startupContext = createManagedObjectContext(startUpDbURL, startupDbOptions, &error);
    CRITTERCISM_LOG_ERROR(error);
    startupContext.undoManager = nil;

    if (![settings.hasCopiedSampleRecipes boolValue]) {
      loadSampleRecipesIntoContext(self.managedObjectContext, startupContext, &error);
      CRITTERCISM_LOG_ERROR(error);
      settings.hasCopiedSampleRecipes = @(YES);
    }

    if (loadStartupDataIntoContext(self.managedObjectContext, startupContext, &error)) {
      settings.copiedStarterDataVersion = currentVersion;
    }
  }

  [self.managedObjectContext save:nil];

  UINavigationController *nav = (UINavigationController *)[[self window] rootViewController];
  OBRecipeListViewController *recipeVc = (OBRecipeListViewController *)nav.topViewController;
  NSAssert(recipeVc.class == OBRecipeListViewController.class,
           @"Unexpected view controller: %@", recipeVc.class);

  recipeVc.moc = self.managedObjectContext;
  recipeVc.settings = settings;
  
  return YES;
}

- (OBSettings *)settingsForContext:(NSManagedObjectContext *)moc;
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

- (void)initializeCrittercism
{
//  if (DEBUG) {
//    [Crittercism enableWithAppID:CRITTER_APP_ID_DEVELOPMENT];
//  } else {
//    [Crittercism enableWithAppID:CRITTER_APP_ID_PRODUCTION];
//  }
}

- (void)initializeGoogleAnalytics
{
  // Optional: automatically send uncaught exceptions to Google Analytics.
  [GAI sharedInstance].trackUncaughtExceptions = NO;

  // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
  [GAI sharedInstance].dispatchInterval = 20;

  // Initialize tracker. Replace with your tracking ID.
  [[GAI sharedInstance] trackerWithTrackingId:@"UA-64333354-1"];
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
