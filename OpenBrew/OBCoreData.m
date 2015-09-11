//
//  OBCoreData.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBCoreData.h"
#import "OBHops.h"

BOOL _deleteAllObjectsForEntity(NSManagedObjectContext *context, NSString *entityName, NSError **error);

BOOL _loadStartupEntity(NSManagedObjectContext *mainMoc,
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
  moc.undoManager = nil;

  return moc;
}

#define RETURN_FALSE_IF_ERROR(error) do { \
  if (error) return NO; \
} while (0)

BOOL loadStartupDataIntoContext(NSManagedObjectContext *moc, NSManagedObjectContext *startupContext, NSError **error)
{
  _deleteAllObjectsForEntity(moc, @"Hops", error);
  _loadStartupEntity(moc, startupContext, @"Hops", error);
  RETURN_FALSE_IF_ERROR(*error);

  _deleteAllObjectsForEntity(moc, @"Malt", error);
  _loadStartupEntity(moc, startupContext, @"Malt", error);
  RETURN_FALSE_IF_ERROR(*error);

  _deleteAllObjectsForEntity(moc, @"Yeast", error);
  _loadStartupEntity(moc, startupContext, @"Yeast", error);
  RETURN_FALSE_IF_ERROR(*error);

  return YES;
}

BOOL _deleteAllObjectsForEntity(NSManagedObjectContext *context, NSString *entityName, NSError **error)
{
  NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
  request.includesPropertyValues = NO;
  request.includesSubentities = NO;

  NSArray *objects = [context executeFetchRequest:request error:error];
  RETURN_FALSE_IF_ERROR(*error);

  for (NSManagedObject *object in objects) {
    [context deleteObject:object];
  }

  return YES;
}

BOOL _loadStartupEntity(NSManagedObjectContext *mainMoc,
                       NSManagedObjectContext *startupMoc,
                       NSString *entityName,
                       NSError **error)
{
  NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
  request.includesSubentities = NO;

  NSArray *startupEntities = [startupMoc executeFetchRequest:request error:error];
  RETURN_FALSE_IF_ERROR(*error);

  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
                                                       inManagedObjectContext:mainMoc];

  NSArray *entityProperties = entityDescription.attributesByName.allKeys;
  NSCAssert(entityDescription.relationshipsByName.count == 0,
            @"This method is coded to only copy properties, but it contains some relationships: %@",
            entityDescription.relationshipsByName.allKeys);

  for (NSManagedObject *object in startupEntities) {
    NSManagedObject *copiedObject = [[NSManagedObject alloc] initWithEntity:entityDescription
                                             insertIntoManagedObjectContext:mainMoc];

    NSDictionary *values = [object dictionaryWithValuesForKeys:entityProperties];
    [copiedObject setValuesForKeysWithDictionary:values];
    [mainMoc insertObject:copiedObject];
  }

  return YES;
}
