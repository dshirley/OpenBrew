//
//  OBYeast.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OBIngredientCatalog, OBYeastAddition;

@interface OBYeast : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * referenceLink;
@property (nonatomic, retain) NSNumber * attenuationMaxPercent;
@property (nonatomic, retain) NSNumber * attenuationMinPercent;

- (float)estimatedAttenuationAsDecimal;

@end
