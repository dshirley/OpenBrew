//
//  OBAppDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/10/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBAppDelegate.h"
#import "OBMalt.h"
#import "OBIngredientCatalog.h"
#import "OBRecipeNavigationController.h"
#import "OBBrewery.h"

@implementation OBAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self loadBrewery];
  
  OBRecipeNavigationController *nav = (OBRecipeNavigationController *) [[self window] rootViewController];
  [nav setManagedContext:[self managedObjectContext]];
  
  return YES;
}

- (id)loadBrewery {
  NSString *catalogPath = [[NSBundle mainBundle]
                           pathForResource:@"MaltCatalog.csv"
                           ofType:nil];
  
  NSString *maltCatalogCsv = [NSString stringWithContentsOfFile:catalogPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
  
  NSArray *malts = [maltCatalogCsv componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  
  NSManagedObjectContext *ctx = [self managedObjectContext];

  OBBrewery *brewery = [NSEntityDescription insertNewObjectForEntityForName:@"Brewery"
                                             inManagedObjectContext:ctx];
  
  OBIngredientCatalog *catalog = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"IngredientCatalog"
                                  inManagedObjectContext:ctx];
  
  [brewery setIngredientCatalog:catalog];
  
  for (NSString *maltData in malts) {
    NSArray *attributes = [maltData componentsSeparatedByString:@","];
    
    OBMalt *malt = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Malt"
                    inManagedObjectContext:ctx];
    
    // TODO: get rid of magic numbers
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [malt setName:attributes[0]];
    [malt setDefaultExtractPotential:[nf numberFromString:attributes[1]]];
    [malt setDefaultLovibond:[nf numberFromString:attributes[3]]];
    
    [catalog addMaltsObject:malt];
  }
  
  return brewery;

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
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
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
