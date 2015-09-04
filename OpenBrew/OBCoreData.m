//
//  OBCoreData.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBCoreData.h"

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
