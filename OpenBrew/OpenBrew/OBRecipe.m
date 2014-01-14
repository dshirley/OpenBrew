//
//  OBRecipe.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBRecipe.h"
#import "OBYeast.h"

@interface OBRecipe()

@property (retain, nonatomic) NSMutableArray *malts;
@property (retain, nonatomic) NSMutableArray *hops;

@end

@implementation OBRecipe

- (float)originalGravity {
  // FIXME
  return 0;
}

- (float)IBUs {
  // FIXME
  return 0;
}

- (float)alcoholByVolume {
  // FIXME
  return 0;
}

- (void)save {
  // FIXME
}

@end
