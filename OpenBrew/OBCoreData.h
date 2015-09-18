//
//  OBCoreData.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NSManagedObjectContext *createManagedObjectContext(NSURL *storeUrl, NSDictionary *storeOptions, NSError **error);

BOOL loadStartupDataIntoContext(NSManagedObjectContext *moc, NSManagedObjectContext *startupContext, NSError **error);
