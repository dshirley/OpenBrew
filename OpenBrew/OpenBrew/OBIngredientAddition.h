//
//  OBIngredientAddition.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/8/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

// This protocol facilitates code reuse by declaring some of the similarities
// of OBMaltAddition and OBHopAddition. There are potentially more similarities
// than are declared here in this protocol; however, we'll only declare the
// similarities that are being exploited.
@protocol OBIngredientAddition <NSObject>

- (void)setDisplayOrder:(NSNumber *)newOrder;

- (void)removeFromRecipe;

@end
