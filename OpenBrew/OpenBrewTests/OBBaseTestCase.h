//
//  OBBaseTestCase.h
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBBrewery.h"

@interface OBBaseTestCase : XCTestCase
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *ctx;
@property (nonatomic, strong) OBBrewery *brewery;
@end
