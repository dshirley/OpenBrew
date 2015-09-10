//
//  OBYeastAdditionTest.m
//  OpenBrew
//
//  Created by David Shirley 2 on 9/9/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBYeast.h"
#import "OBYeastAddition.h"
#import "OBBaseTestCase.h"

@interface OBYeastAdditionTest : OBBaseTestCase

@end

@implementation OBYeastAdditionTest

- (void)testInitWithYeast
{
  OBYeast *yeast = [self addYeast:@"WLP001"];
  OBYeastAddition *yeastAddition = [[OBYeastAddition alloc] initWithYeast:yeast
                                                                andRecipe:self.recipe];

  NSArray *yeastAttributes = yeast.entity.attributesByName.allKeys;
  for (NSString *key in yeastAttributes) {
    XCTAssertEqualObjects([yeast valueForKey:key], [yeastAddition valueForKey:key]);
  }

  XCTAssertEqualObjects(@(0), yeastAddition.quantity);
  XCTAssertEqual(self.recipe, yeastAddition.recipe);
}

@end
