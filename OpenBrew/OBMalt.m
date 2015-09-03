//
//  OBMalt.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMalt.h"
#import "OBMaltAddition.h"
#import "Crittercism+NSErrorLogging.h"

#define MALT_NAME_IDX 0
#define MALT_EXTRACT_IDX 1
#define MALT_COLOR_IDX 2
#define MALT_TYPE_IDX 3

@implementation OBMalt

@dynamic defaultExtractPotential;
@dynamic defaultLovibond;
@dynamic name;
@dynamic type;

- (id)initWithContext:(NSManagedObjectContext *)moc
           andCsvData:(NSArray *)csvData
{
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  return [self initWithContext:moc
                          name:csvData[MALT_NAME_IDX]
              extractPotential:[nf numberFromString:csvData[MALT_EXTRACT_IDX]]
                      lovibond:[nf numberFromString:csvData[MALT_COLOR_IDX]]
                          type:[nf numberFromString:csvData[MALT_TYPE_IDX]]];
}

- (id)initWithContext:(NSManagedObjectContext *)moc
                 name:(NSString *)name
     extractPotential:(NSNumber *)extractPotential
             lovibond:(NSNumber *)lovibond
                 type:(NSNumber *)type
{
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Malt"
                                          inManagedObjectContext:moc];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:moc]) {
    self.name = name;
    self.defaultExtractPotential = extractPotential;
    self.defaultLovibond = lovibond;
    self.type = type;
  }

  return self;
}

@end
