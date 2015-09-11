//
//  OBHops.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHops.h"
#import "OBHopAddition.h"

#define HOP_NAME_IDX 0
#define HOP_ALPHA_IDX 1

@implementation OBHops

@dynamic alphaAcidPercent;
@dynamic name;

- (id)initWithContext:(NSManagedObjectContext *)moc
           andCsvData:(NSArray *)csvData
{
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  return [self initWithContext:moc
                          name:csvData[HOP_NAME_IDX]
              alphaAcidPercent:[nf numberFromString:csvData[HOP_ALPHA_IDX]]];
}

- (id)initWithContext:(NSManagedObjectContext *)moc
                 name:(NSString *)name
     alphaAcidPercent:(NSNumber *)alphaAcidPercent
{
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"Hops"
                                          inManagedObjectContext:moc];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:moc]) {
    self.name = name;
    self.alphaAcidPercent = alphaAcidPercent;
  }

  return self;
}

@end
