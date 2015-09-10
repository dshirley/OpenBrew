//
//  OBYeast.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBYeastAddition;

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

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSNumber *category;
@property (nonatomic) NSNumber *manufacturer;
@property (nonatomic) NSNumber *alcoholTolerance;
@property (nonatomic) NSNumber *flocculation;
@property (nonatomic) NSNumber *maxAttenuation;
@property (nonatomic) NSNumber *minAttenuation;
@property (nonatomic) NSNumber *maxTemperature;
@property (nonatomic) NSNumber *minTemperature;

- (float)estimatedAttenuationAsDecimal;

- (id)initWithContext:(NSManagedObjectContext *)moc
           andCsvData:(NSArray *)data;

@end
