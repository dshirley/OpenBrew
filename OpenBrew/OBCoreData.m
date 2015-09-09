//
//  OBCoreData.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBCoreData.h"
#import "OBHops.h"

BOOL loadStartupEntity(NSManagedObjectContext *mainMoc,
                       NSManagedObjectContext *startupMoc,
                       NSString *entityName,
                       NSError **error);

NSManagedObjectContext *createManagedObjectContext(NSURL *storeUrl, NSError **error)
{
  NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];

  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OpenBrew"
                                            withExtension:@"momd"];

  NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

  NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
  if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                 configuration:nil
                                           URL:storeUrl
                                       options:nil
                                         error:error]) {
    return nil;
  }

  moc.persistentStoreCoordinator = coordinator;

  return moc;
}

#define RETURN_FALSE_IF_ERROR(error) do { \
  if (error) return NO; \
} while (0)

BOOL loadStartupDataIntoContext(NSManagedObjectContext *moc, NSURL *startUpDbURL, NSError **error)
{
  NSDate *start = [NSDate date];

  NSManagedObjectContext *startupContext = createManagedObjectContext(startUpDbURL, error);
  startupContext.undoManager = nil;
  RETURN_FALSE_IF_ERROR(*error);

  loadStartupEntity(moc, startupContext, @"Hops", error);
  RETURN_FALSE_IF_ERROR(*error);

  loadStartupEntity(moc, startupContext, @"Malts", error);
  RETURN_FALSE_IF_ERROR(*error);

  NSLog(@"Data load time: %f", [[NSDate date] timeIntervalSinceDate:start]);

  return YES;
}

BOOL loadStartupEntity(NSManagedObjectContext *mainMoc,
                       NSManagedObjectContext *startupMoc,
                       NSString *entityName,
                       NSError **error)
{
  NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
  request.includesPropertyValues = NO;

  NSArray *mainDbEntities = [mainMoc executeFetchRequest:request error:error];
  RETURN_FALSE_IF_ERROR(*error);

  for (NSManagedObject *object in mainDbEntities) {
    [mainMoc deleteObject:object];
  }

  NSArray *startupEntities = [startupMoc executeFetchRequest:request error:error];
  RETURN_FALSE_IF_ERROR(*error);

  for (NSManagedObject *object in startupEntities) {
    [startupMoc insertObject:object];
  }

  return YES;
}
