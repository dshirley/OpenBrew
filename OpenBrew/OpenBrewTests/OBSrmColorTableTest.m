//
//  OBSrmColorTableTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/2/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBSrmColorTable.h"

@interface OBSrmColorTableTest : XCTestCase

@end

@implementation OBSrmColorTableTest

- (void)testColorForSrm
{
  XCTAssertEqualObjects([UIColor clearColor], colorForSrm(0));

  for (uint32_t srm = 0; srm < 100; srm++) {
    UIColor *color = colorForSrm(srm);

    XCTAssertNotNil(color);

    // Its a common mistake to initialize colors with integers rather than floats [0, 1]
    // That results in the color white.
    XCTAssertNotEqualObjects([UIColor whiteColor], color);
  }
}

@end
