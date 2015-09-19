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

BOOL _copyAllEntityFromStartupDb(NSManagedObjectContext *mainMoc,
                                 NSManagedObjectContext *startupMoc,
                                 NSString *entityName,
                                 NSError **error);

NSManagedObject *_copyObjectIntoContext(NSManagedObject *objectToCopy,
                                        NSManagedObjectContext *mocToCopyTo);

NSManagedObjectContext *createManagedObjectContext(NSURL *storeUrl, NSDictionary *storeOptions, NSError **error)
{
  NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];

  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OpenBrew"
                                            withExtension:@"momd"];

  NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

  NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
  if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                 configuration:nil
                                           URL:storeUrl
                                       options:storeOptions
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
  _copyAllEntityFromStartupDb(moc, startupContext, @"Hops", error);
  RETURN_FALSE_IF_ERROR(*error);

  _deleteAllObjectsForEntity(moc, @"Malt", error);
  _copyAllEntityFromStartupDb(moc, startupContext, @"Malt", error);
  RETURN_FALSE_IF_ERROR(*error);

  _deleteAllObjectsForEntity(moc, @"Yeast", error);
  _copyAllEntityFromStartupDb(moc, startupContext, @"Yeast", error);
  RETURN_FALSE_IF_ERROR(*error);

  return YES;
}

BOOL loadSampleRecipesIntoContext(NSManagedObjectContext *moc, NSManagedObjectContext *startupContext, NSError **error)
{
  _copyAllEntityFromStartupDb(moc, startupContext, @"Recipe", error);
  RETURN_FALSE_IF_ERROR(error);
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

BOOL _copyAllEntityFromStartupDb(NSManagedObjectContext *mainMoc,
                                 NSManagedObjectContext *startupMoc,
                                 NSString *entityName,
                                 NSError **error)
{
  NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
  request.includesSubentities = NO;

  NSArray *startupEntities = [startupMoc executeFetchRequest:request error:error];
  RETURN_FALSE_IF_ERROR(*error);

  for (NSManagedObject *object in startupEntities) {
    _copyObjectIntoContext(object, mainMoc);
  }

  return YES;
}

NSManagedObject *__copyObjectIntoContext(NSManagedObject *objectToCopy,
                                         NSManagedObjectContext *mocToCopyTo,
                                         NSMutableSet *seenObjects)
{
  [seenObjects addObject:objectToCopy];

  NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:objectToCopy.entity.name];
  request.includesSubentities = NO;

  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:objectToCopy.entity.name
                                                       inManagedObjectContext:mocToCopyTo];

  // Copy all of the properties
  NSArray *entityProperties = entityDescription.attributesByName.allKeys;

  NSManagedObject *copiedObject = [[NSManagedObject alloc] initWithEntity:entityDescription
                                           insertIntoManagedObjectContext:mocToCopyTo];

  NSDictionary *values = [objectToCopy dictionaryWithValuesForKeys:entityProperties];
  [copiedObject setValuesForKeysWithDictionary:values];
  [mocToCopyTo insertObject:copiedObject];

  // Recursively copy the entities
  for (NSString *name in entityDescription.relationshipsByName.allKeys) {
    NSRelationshipDescription *relationshipDescription = entityDescription.relationshipsByName[name];

    if (relationshipDescription.isToMany) {
      NSMutableSet *setOfObjectToCopy = [objectToCopy mutableSetValueForKey:name];
      NSMutableSet *setOfCopiedObject = [copiedObject mutableSetValueForKey:name];

      for (NSManagedObject *relationshipObject in setOfObjectToCopy) {
        if (![seenObjects containsObject:relationshipObject]) {
          NSManagedObject *copiedRelationshipObject = __copyObjectIntoContext(relationshipObject,
                                                                              mocToCopyTo,
                                                                              seenObjects);
          [setOfCopiedObject addObject:copiedRelationshipObject];
        }
      }
    } else {
      NSManagedObject *relationshipObject = [objectToCopy valueForKey:name];
      if (![seenObjects containsObject:relationshipObject]) {
        NSManagedObject *copiedRelationshipObject = __copyObjectIntoContext(relationshipObject, mocToCopyTo, seenObjects);
        [copiedObject setValue:copiedRelationshipObject forKey:name];
      }

    }
  }

  return copiedObject;
}

NSManagedObject *_copyObjectIntoContext(NSManagedObject *objectToCopy,
                                        NSManagedObjectContext *mocToCopyTo)
{
  return __copyObjectIntoContext(objectToCopy,
                                 mocToCopyTo,
                                 [NSMutableSet set]);
}















