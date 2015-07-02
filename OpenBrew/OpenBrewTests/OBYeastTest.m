//
//  OBYeastTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBYeast.h"

@interface OBYeastTest : OBBaseTestCase

@end

@implementation OBYeastTest

- (void)testInitWithCatalogAndCsvData
{
  NSArray *csvData = @[ @"Wyeast", @"Ale", @"1187", @"Ringwood Ale", @"68", @"72", @"4", @"64", @"74", @"1"];
  OBYeast *yeast = [[OBYeast alloc] initWithCatalog:self.brewery.ingredientCatalog andCsvData:csvData];

  XCTAssertEqual(OBYeastManufacturerWyeast, [yeast.manufacturer integerValue]);
  XCTAssertEqual(OBYeastCategoryAle, [yeast.category integerValue]);
  XCTAssertEqualObjects(@"1187", yeast.identifier);
  XCTAssertEqualObjects(@"Ringwood Ale", yeast.name);
  XCTAssertEqual(68, [yeast.minAttenuation integerValue]);
  XCTAssertEqual(72, [yeast.maxAttenuation integerValue]);
  XCTAssertEqual(OBYeastFlocculationLevelHigh, [yeast.flocculation integerValue]);
  XCTAssertEqual(64, [yeast.minTemperature integerValue]);
  XCTAssertEqual(74, [yeast.maxTemperature integerValue]);
  XCTAssertEqual(OBYeastAlcoholToleranceLevelMedium, [yeast.alcoholTolerance integerValue]);
}

- (void)testCategoryParsing
{
  // The values correspond to the values in OBYeastCategory
  NSArray *categories = @[ @"Ale", @"Lager", @"Belgian", @"Lambic" ];
  int i = 0;

  for (NSString *category in categories) {
    NSArray *csvData = @[ @"Wyeast", category, @"0", @"Test", @"0", @"0", @"0", @"0", @"0", @"0"];
    OBYeast *yeast = [[OBYeast alloc] initWithCatalog:self.brewery.ingredientCatalog andCsvData:csvData];
    XCTAssertEqual((OBYeastCategory) i, [yeast.category integerValue]);
    i++;
  }
}

- (void)testManufacturerParsing
{
  // The values correspond to the values in OBYeastCategory
  NSArray *manufacturers = @[ @"White Labs", @"Wyeast" ];
  int i = 0;

  for (NSString *manufacturer in manufacturers) {
    NSArray *csvData = @[ manufacturer, @"Ale", @"0", @"Test", @"0", @"0", @"0", @"0", @"0", @"0"];
    OBYeast *yeast = [[OBYeast alloc] initWithCatalog:self.brewery.ingredientCatalog andCsvData:csvData];
    XCTAssertEqual((OBYeastManufacturer) i, [yeast.manufacturer integerValue]);
    i++;
  }
}

- (void)testEstimatedAttenuationAsDecimal
{
  NSArray *csvData = @[ @"Wyeast", @"Ale", @"1187", @"Ringwood Ale", @"68", @"72", @"4", @"64", @"74", @"1"];
  OBYeast *yeast = [[OBYeast alloc] initWithCatalog:self.brewery.ingredientCatalog andCsvData:csvData];

  yeast.minAttenuation = @(60);
  yeast.maxAttenuation = @(70);

  XCTAssertEqualWithAccuracy(.65, [yeast estimatedAttenuationAsDecimal], 0.001);

}

@end
