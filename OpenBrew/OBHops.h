//
//  OBHops.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBHopAddition, OBIngredientCatalog;

@interface OBHops : NSManagedObject

@property (nonatomic, retain) OBIngredientCatalog *catalog;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * defaultAlphaAcidPercent;

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
           andCsvData:(NSArray *)csvData;

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
                 name:(NSString *)name
     alphaAcidPercent:(NSNumber *)alphaAcidPercent;

@end
