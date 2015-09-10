//
//  OBYeast.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBYeast.h"
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

- (id)initWithContext:(NSManagedObjectContext *)moc
           andCsvData:(NSArray *)data;
{
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Yeast"
                                          inManagedObjectContext:moc];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:moc]) {
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

// It seems Brewing Classic Styles always reports on the high end.
// This is typically what I experience with my beers as well.
- (float)estimatedAttenuationAsDecimal {
  return [[self maxAttenuation] floatValue] / 100.0;
}

@end
