//
//  OBBrewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 6/19/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//
//  All of the controllers in this project contain a recipe, but they don't
//  necessarily need to all extend UIViewController (though I believe they
//  currently do).  We need a common way to set the recipe so that a bunch
//  of casts are not needed.

#import <Foundation/Foundation.h>

@class OBRecipe;

@protocol OBBrewController <NSObject>

- (void)setRecipe:(OBRecipe *)recipe;

@end
