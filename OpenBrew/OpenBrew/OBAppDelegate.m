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
#import "OBIngredientCatalog.h"
#import "OBRecipeNavigationController.h"
#import "OBBrewery.h"
#import "Crittercism.h"
#import "Crittercism+NSErrorLogging.h"

static NSString *const CRITTER_APP_ID_PRODUCTION = @"540b2fc9d478bc6abf000001";
static NSString *const CRITTER_APP_ID_DEVELOPMENT = @"540b2fe1bb947505e5000003";

@implementation OBAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  if (DEBUG) {
    [Crittercism enableWithAppID:CRITTER_APP_ID_DEVELOPMENT];
  } else {
    [Crittercism enableWithAppID:CRITTER_APP_ID_PRODUCTION];
  }

  OBBrewery *brewery = [OBBrewery breweryFromContext:self.managedObjectContext];
  if (brewery) {
    [self.managedObjectContext save:nil];
  } else {
    // TODO: maybe this should go into the brewery initializer? That could have unwanted
    // side effects, though. Maybe we pass an error and check if there was an error and then
    // abort.  Maybe there's a notion of a transaction that can be used to ensure
    // brewery initialization happens atomically.
    [self.managedObjectContext reset];
  }

  OBRecipeNavigationController *nav = (OBRecipeNavigationController *) [[self window] rootViewController];
  nav.managedContext = self.managedObjectContext;
  nav.brewery = brewery;
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

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

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  
  return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OpenBrew"
                                            withExtension:@"momd"];
  
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
  if (_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OpenBrew.sqlite"];
  
  NSError *error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:storeURL
                                                       options:nil
                                                         error:&error]) {
    CRITTERCISM_LOG_ERROR(error);
  }
  
  return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
