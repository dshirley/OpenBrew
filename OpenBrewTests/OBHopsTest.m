//
//  OBHopsTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBBaseTestCase.h"
#import "OBHops.h"

@interface OBHopsTest : OBBaseTestCase

@end

@implementation OBHopsTest

- (void)testInitWithCatalogAndCsvData
{
  NSArray *csvData = @[ @"Glacier", @"5.6", @"US" ];
  OBHops *hops = [[OBHops alloc] initWithContext:self.ctx andCsvData:csvData];

  XCTAssertEqualObjects(@"Glacier", hops.name);
  XCTAssertEqualWithAccuracy(5.6, [hops.alphaAcidPercent floatValue], 0.0001);

  csvData = @[ @"Cluster", @"7", @"US" ];
  hops = [[OBHops alloc] initWithContext:self.ctx andCsvData:csvData];

  XCTAssertEqualObjects(@"Cluster", hops.name);
  XCTAssertEqualWithAccuracy(7, [hops.alphaAcidPercent floatValue], 0.0001);

}

- (void)testInitWithCatalogNameAlphaAcidPercent
{
  OBHops *hops = [[OBHops alloc] initWithContext:self.ctx
                                            name:@"Cascade"
                                alphaAcidPercent:@(5.85)];

  XCTAssertEqualObjects(@"Cascade", hops.name);
  XCTAssertEqualWithAccuracy(5.85, [hops.alphaAcidPercent floatValue], 0.0001);
}

@end
