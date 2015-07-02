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

- (id)fetchEntity:(NSString *)entityName
     withProperty:(NSString *)property
          equalTo:(NSString *)value
{
  NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName
                                                       inManagedObjectContext:self.ctx];

  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entityDescription];

  NSString *query = [NSString stringWithFormat:@"(%@ == '%@')", property, value];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
  [request setPredicate:predicate];

  NSError *error = nil;
  NSArray *array = [self.ctx executeFetchRequest:request error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(array);
  XCTAssertEqual(1, array.count, @"%@", array);


  if (array.count >= 1) {
    return array[0];
  } else {
    return nil;
  }
}

@end
