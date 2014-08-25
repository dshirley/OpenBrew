//
//  OBRecipeNavigationController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 2/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBBrewery;

@interface OBRecipeNavigationController : UINavigationController

@property (nonatomic, strong) NSManagedObjectContext *managedContext;
@property (nonatomic, strong) OBBrewery *brewery;

@end
