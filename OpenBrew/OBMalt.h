//
//  OBMalt.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBMaltAddition;

typedef NS_ENUM(NSInteger, OBMaltType) {
  OBMaltTypeGrain,
  OBMaltTypeSugar,
  OBMaltTypeExtract
};

@interface OBMalt : NSManagedObject

@property (nonatomic, retain) NSString *name;

// Malt, sugar, extract
@property (nonatomic, retain) NSNumber *type;
@property (nonatomic, retain) NSNumber *defaultLovibond;
@property (nonatomic, retain) NSNumber *defaultExtractPotential;

- (id)initWithContext:(NSManagedObjectContext *)moc
           andCsvData:(NSArray *)data;

- (id)initWithContext:(NSManagedObjectContext *)moc
                 name:(NSString *)name
     extractPotential:(NSNumber *)extractPotential
             lovibond:(NSNumber *)lovibond
                 type:(NSNumber *)type;

@end

@interface OBMalt (CoreDataGeneratedAccessors)

- (void)addMaltAdditionsObject:(OBMaltAddition *)value;
- (void)removeMaltAdditionsObject:(OBMaltAddition *)value;
- (void)addMaltAdditions:(NSSet *)values;
- (void)removeMaltAdditions:(NSSet *)values;

@end
