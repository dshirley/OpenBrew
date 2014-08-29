//
//  OBYeast.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBIngredientCatalog, OBYeastAddition;

typedef NS_ENUM(NSInteger, OBYeastFlocculationLevel) {
  OBYeastFlocculationLevelLow,
  OBYeastFlocculationLevelMediumLow,
  OBYeastFlocculationLevelMedium,
  OBYeastFlocculationLevelMediumHigh,
  OBYeastFlocculationLevelHigh,
};

typedef NS_ENUM(NSInteger, OBYeastAlcoholToleranceLevel) {
  OBYeastAlcoholToleranceLevelLow,
  OBYeastAlcoholToleranceLevelMedium,
  OBYeastAlcoholToleranceLevelHigh,
  OBYeastAlcoholToleranceLevelVeryHigh
};

typedef NS_ENUM(NSInteger, OBYeastCategory) {
  OBYeastCategoryAle,
  OBYeastCategoryLager,
  OBYeastCategoryBelgian,
  OBYeastCategoryLambic
};

typedef NS_ENUM(NSInteger, OBYeastManufacturer) {
  OBYeastManufacturerWhiteLabs,
  OBYeastManufacturerWyeast
};

@interface OBYeast : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * manufacturer;
@property (nonatomic, retain) NSNumber * alcoholTolerance;
@property (nonatomic, retain) NSNumber * flocculation;
@property (nonatomic, retain) NSNumber * maxAttenuation;
@property (nonatomic, retain) NSNumber * minAttenuation;
@property (nonatomic, retain) NSNumber * maxTemperature;
@property (nonatomic, retain) NSNumber * minTemperature;

@property (nonatomic, retain) OBIngredientCatalog *catalog;

- (float)estimatedAttenuationAsDecimal;

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
           andCsvData:(NSArray *)data;

@end
