//
//  OBIngredientTableViewDataSource.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

// A generic class for displaying ingredients.  Ingredients must have a
// 'name' property.
@interface OBIngredientTableViewDataSource : NSObject <UITableViewDataSource>

// Specify a predicate to filter what gets displayed
@property (nonatomic) NSPredicate *predicate;

// The entity name refers to a CoreData entity name.  This class will do
// a fetch request that will be used to display a full list of ingredients.
- (id)initIngredientEntityName:(NSString *)entityName
       andManagedObjectContext:(NSManagedObjectContext *)ctx;

- (id)ingredientAtIndexPath:(NSIndexPath *)indexPath;

@end
