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

  @autoreleasepool {
    NSString *pathToSaveData = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];

    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToSaveData]) {
      NSLog(@"File already exists at path %@", pathToSaveData);
      return 1;
    }

    NSURL *url = [[NSURL alloc] initFileURLWithPath:pathToSaveData];

    NSError *error = nil;
    NSManagedObjectContext *moc = createManagedObjectContext(url, &error);

    if (error) {
      NSLog(@"Error creating managed object context: %@", error);
      return 1;
    }

    OBDataLoader *loader = [[OBDataLoader alloc] initWithContext:moc];

    if (![loader loadData]) {
      return 1;
    }

    [moc save:&error];
    if (error) {
      NSLog(@"Error saving data: %@", error);
      return 1;
    }
  }

  return 0;
}

