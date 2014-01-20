//
//  OBYeast.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/13/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBYeast : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *referenceLink;
@property (nonatomic, assign) float attanuationMinPercent;
@property (nonatomic, assign) float attanuationMaxPercent;

- (float)estimatedAttenuationAsDecimal;

@end

@interface OBYeastAddition : NSManagedObject
@property (nonatomic, strong) OBYeast *yeast;
@property (nonatomic, assign) int quantity;
@end
