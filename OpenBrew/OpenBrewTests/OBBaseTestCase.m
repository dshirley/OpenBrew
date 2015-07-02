//
//  OBBaseTestCase.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"

@implementation OBBaseTestCase

- (void)setUp {
  [super setUp];
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OpenBrew"
                                            withExtension:@"momd"];

  self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
  XCTAssertNotNil([self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                                configuration:nil
                                                                          URL:nil
                                                                      options:nil
                                                                        error:NULL]);

  self.ctx = [[NSManagedObjectContext alloc] init];
  self.ctx.persistentStoreCoordinator = self.persistentStoreCoordinator;

  self.brewery = [OBBrewery breweryFromContext:self.ctx];
}

- (void)tearDown {
  self.ctx = nil;
  [super tearDown];
}

@end
