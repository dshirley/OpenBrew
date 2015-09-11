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

@property (nonatomic) NSString *name;

// Malt, sugar, extract
@property (nonatomic) NSNumber *type;
@property (nonatomic) NSNumber *lovibond;
@property (nonatomic) NSNumber *extractPotential;

- (id)initWithContext:(NSManagedObjectContext *)moc
           andCsvData:(NSArray *)data;

- (id)initWithContext:(NSManagedObjectContext *)moc
                 name:(NSString *)name
     extractPotential:(NSNumber *)extractPotential
             lovibond:(NSNumber *)lovibond
                 type:(NSNumber *)type;

- (BOOL)isGrain;
- (BOOL)isSugar;
- (BOOL)isExtract;

@end

@interface OBMalt (CoreDataGeneratedAccessors)

- (void)addMaltAdditionsObject:(OBMaltAddition *)value;
- (void)removeMaltAdditionsObject:(OBMaltAddition *)value;
- (void)addMaltAdditions:(NSSet *)values;
- (void)removeMaltAdditions:(NSSet *)values;

@end
