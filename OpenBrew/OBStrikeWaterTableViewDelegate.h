//
//  OBMashCalculationsTableViewDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBDrawerTableViewDelegate.h"

@interface OBStrikeWaterTableViewDelegate : OBDrawerTableViewDelegate

@property (nonatomic) NSNumber *grainWeightInPounds;
@property (nonatomic) NSNumber *grainTemperatureInFahrenheit;
@property (nonatomic) NSNumber *waterVolumeInGallons;
@property (nonatomic) NSNumber *targetTemperatureInFahrenheit;

- (instancetype)initWithGACategory:(NSString *)gaCategory;

#pragma mark Template Methods

- (NSArray *)ingredientData;

- (void)populateIngredientCell:(UITableViewCell *)cell
            withIngredientData:(id)ingredientData;

- (void)populateDrawerCell:(UITableViewCell *)cell
        withIngredientData:(id)ingredientData;

@end
