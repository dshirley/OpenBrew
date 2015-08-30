//
//  OBBrewery.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//
//  TODO: Change the name of this class to "OBSettings"
//  TODO: Make all retain properties "strong"
//  TODO: replace NSAsserts with CR_LOG_ERRORS

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OBYeast.h"

typedef NS_ENUM(NSInteger, OBGaugeMetric) {
  OBMetricOriginalGravity,
  OBMetricFinalGravity,
  OBMetricAbv,
  OBMetricColor,
  OBMetricIbu,
  OBMetricBuToGuRatio, // TODO: rename to BuToGravity (find all other places, too)
};

typedef NS_ENUM(NSInteger, OBMaltAdditionMetric) {
  OBMaltAdditionMetricWeight,
  OBMaltAdditionMetricPercentOfGravity
};

typedef NS_ENUM(NSInteger, OBHopAdditionMetric) {
  OBHopAdditionMetricWeight,
  OBHopAdditionMetricIbu
};

@interface OBBrewery : NSManagedObject

@property (nonatomic, retain) NSNumber *mashEfficiency;
@property (nonatomic, retain) NSNumber *defaultBatchSize;

// OBMaltAdditionMetric which corresponds to what type of metric to display for
// each malt addition on the right hand of the OBMaltAdditionViewController
@property (nonatomic, strong) NSNumber *maltAdditionDisplayMetric;

// OBGaugeMetric to display for the gauge of the OBMaltAdditionViewController
@property (nonatomic, strong) NSNumber *maltGaugeDisplayMetric;

// An OBHopAdditionMetric describes what to display for each cell of the OBHopAdditionViewController
@property (nonatomic, strong) NSNumber *hopAdditionDisplayMetric;

// OBGaugeMetric to display for the gauge of the OBHopAdditionViewController
@property (nonatomic, strong) NSNumber *hopGaugeDisplayMetric;

// OBYeastManufacturer selected in the OBYeastAdditionViewController
@property (nonatomic, strong) NSNumber *selectedYeastManufacturer;

@end

@interface OBBrewery (CoreDataGeneratedAccessors)

+ (OBBrewery *)breweryFromContext:(NSManagedObjectContext *)ctx;

@end
