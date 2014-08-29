//
//  OBYeast.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBYeast.h"
#import "OBIngredientCatalog.h"
#import "OBYeastAddition.h"

typedef NS_ENUM(NSInteger, OBYeastCsvIndex) {
  OBYeastCsvManufacturerIndex,
  OBYeastCsvCategortyIndex,
  OBYeastCsvIdentifierIndex,
  OBYeastCsvNameIndex,
  OBYeastCsvMinAttenuationIndex,
  OBYeastCsvMaxAttenuationIndex,
  OBYeastCsvFloculationIndex,
  OBYeastCsvMinTemperatureIndex,
  OBYeastCsvMaxTemperatureIndex,
  OBYeastCsvAlcoholTolleranceIndex
};

@implementation OBYeast

@dynamic name;
@dynamic identifier;
@dynamic category;
@dynamic manufacturer;
@dynamic alcoholTolerance;
@dynamic flocculation;
@dynamic minAttenuation;
@dynamic maxAttenuation;
@dynamic maxTemperature;
@dynamic minTemperature;
@dynamic catalog;

- (id)initWithCatalog:(OBIngredientCatalog *)catalog
           andCsvData:(NSArray *)data
{
  NSManagedObjectContext *ctx = [catalog managedObjectContext];
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Yeast"
                                          inManagedObjectContext:ctx];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:ctx]) {
    self.catalog = catalog;

    NSString *manufacturerString = data[OBYeastCsvManufacturerIndex];
    if ([manufacturerString isEqualToString:@"Wyeast"]) {
      self.manufacturer = @(OBYeastManufacturerWyeast);
    } else if ([manufacturerString isEqualToString:@"White Labs"]) {
      self.manufacturer = @(OBYeastManufacturerWhiteLabs);
    } else {
      [NSException raise:@"Invalid yeast manufacturer"
                  format:@"%@", manufacturerString];
    }

    NSString *categoryString = data[OBYeastCsvCategortyIndex];
    if ([categoryString isEqualToString:@"Ale"]) {
      self.category = @(OBYeastCategoryAle);
    } else if ([categoryString isEqualToString:@"Lager"]) {
      self.category = @(OBYeastCategoryLager);
    } else if ([categoryString isEqualToString:@"Belgian"]) {
      self.category = @(OBYeastCategoryBelgian);
    } else if ([categoryString isEqualToString:@"Lambic"]) {
      self.category = @(OBYeastCategoryLambic);
    } else {
      [NSException raise:@"Invalid yeast category" format:@"%@", categoryString];
    }

    self.identifier = data[OBYeastCsvIdentifierIndex];
    self.name = data[OBYeastCsvNameIndex];

    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];

    self.minAttenuation = [nf numberFromString:data[OBYeastCsvMinAttenuationIndex]];
    self.maxAttenuation = [nf numberFromString:data[OBYeastCsvMaxAttenuationIndex]];
    self.flocculation = [nf numberFromString:data[OBYeastCsvFloculationIndex]];
    self.minTemperature = [nf numberFromString:data[OBYeastCsvMinTemperatureIndex]];
    self.maxTemperature = [nf numberFromString:data[OBYeastCsvMaxTemperatureIndex]];
    self.alcoholTolerance = [nf numberFromString:data[OBYeastCsvAlcoholTolleranceIndex]];
  }

  return self;
}

- (float)estimatedAttenuationAsDecimal {
  float min = [[self minAttenuation] floatValue];
  float max = [[self maxAttenuation] floatValue];
  return (min + max) / 2;
}

@end
