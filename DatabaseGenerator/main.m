//
//  main.m
//  BrewData
//
//  Created by David Shirley 2 on 9/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OBCoreData.h"
#import "OBDataLoader.h"

int main(int argc, const char * argv[]) {
  if (argc != 2) {
    NSLog(@"An output directory must be specified");
    NSLog(@"Given the following arguments:");
    for (int i = 0; i < argc; i++) {
      NSLog(@"%d: %s", i, argv[i]);
    }

    return 1;
  }

  BOOL dataLoaded = NO;

  @autoreleasepool {
    NSString *pathToSaveData = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];

    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToSaveData]) {
      NSLog(@"File already exists at path %@", pathToSaveData);
      return 1;
    }

    NSURL *url = [[NSURL alloc] initFileURLWithPath:pathToSaveData];

    NSError *error = nil;
    NSManagedObjectContext *moc = createManagedObjectContext(url, &error);

    OBDataLoader *loader = [[OBDataLoader alloc] initWithContext:moc];

    dataLoaded = [loader loadData];
  }

  return !dataLoaded;
}

