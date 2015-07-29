//
//  OBBrewery.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface OBBrewery : NSManagedObject

@property (nonatomic, retain) NSNumber * mashEfficiency;
@property (nonatomic, retain) NSNumber * defaultBatchSize;

@end

@interface OBBrewery (CoreDataGeneratedAccessors)

+ (OBBrewery *)instance;
+ (OBBrewery *)breweryFromContext:(NSManagedObjectContext *)ctx;

@end
