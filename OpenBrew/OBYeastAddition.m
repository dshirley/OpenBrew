//
//  OBYeastAddition.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBYeastAddition.h"
#import "OBRecipe.h"
#import "OBYeast.h"


@implementation OBYeastAddition

@dynamic quantity;
@dynamic recipe;
@dynamic yeast;

- (id)initWithYeast:(OBYeast *)yeast andRecipe:(OBRecipe *)recipe;
{
  NSManagedObjectContext *ctx = [yeast managedObjectContext];
  NSEntityDescription *desc = [NSEntityDescription entityForName:@"YeastAddition"
                                          inManagedObjectContext:ctx];

  if (self = [self initWithEntity:desc insertIntoManagedObjectContext:ctx]) {
    self.yeast = yeast;
    self.quantity = @0;
    self.recipe = recipe;
  }

  return self;
}

@end
