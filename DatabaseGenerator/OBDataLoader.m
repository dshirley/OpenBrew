//
//  OBDataLoader.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OBDataLoader.h"
#import "OBSettings.h"
#import "OBMalt.h"
#import "OBHops.h"
#import "OBYeast.h"

@interface OBDataLoader()

@property (nonatomic) NSManagedObjectContext *moc;
@end

@implementation OBDataLoader

- (instancetype)initWithContext:(NSManagedObjectContext *)moc;
{
  self = [super init];

  if (self) {

    self.moc = moc;
  }

  return self;
}


#pragma mark - Data Loading

- (BOOL)loadData
{
  return [self loadYeast] && [self loadMalts] && [self loadHops];
}

- (BOOL)loadYeast
{
  return [self loadDataIntoContext:self.moc
                          fromPath:@"YeastCatalog.csv"
                         withBlock:^void (NSArray *attributes, NSManagedObjectContext *moc)
          {
            (void)[[OBYeast alloc] initWithContext:moc andCsvData:attributes];
          }];
}

- (BOOL)loadMalts
{
  return [self loadDataIntoContext:self.moc
                          fromPath:@"MaltCatalog.csv"
                         withBlock:^void (NSArray *attributes, NSManagedObjectContext *moc)
          {
            (void)[[OBMalt alloc] initWithContext:moc andCsvData:attributes];
          }];
}

- (BOOL)loadHops
{
  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  return [self loadDataIntoContext:self.moc
                          fromPath:@"HopCatalog.csv"
                         withBlock:^void (NSArray *attributes, NSManagedObjectContext *moc)
          {
            (void)[[OBHops alloc] initWithContext:moc andCsvData:attributes];
          }];
}

- (BOOL)loadDataIntoContext:(NSManagedObjectContext *)moc
                   fromPath:(NSString *)path
                  withBlock:(void (^)(NSArray *, NSManagedObjectContext *))parser
{
  NSString *csvPath = [[NSBundle mainBundle]
                       pathForResource:path
                       ofType:nil];

  NSError *error = nil;
  NSString *csv = [NSString stringWithContentsOfFile:csvPath
                                            encoding:NSUTF8StringEncoding
                                               error:&error];

  NSAssert(!error, @"An error occurred loading %@: %@", csvPath, error);
  if (error) {
    return NO;
  }

  NSArray *lines = [csv componentsSeparatedByCharactersInSet:
                    [NSCharacterSet newlineCharacterSet]];

  NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
  [nf setNumberStyle:NSNumberFormatterDecimalStyle];

  for (NSString *line in lines) {
    if (!line || line.length == 0) {
      continue;
    }

    parser([line componentsSeparatedByString:@","], moc);
  }
  
  return YES;
}

@end
