//
//  OBDataLoader.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBDataLoader : NSObject

- (instancetype)initWithContext:(NSManagedObjectContext *)moc;

- (BOOL)loadData;

@end
