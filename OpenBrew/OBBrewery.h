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

typedef NS_ENUM(NSInteger, OBGaugeMetric) {
  OBMetricOriginalGravity,
  OBMetricFinalGravity,
  OBMetricAbv,
  OBMetricColor,
  OBMetricIbu,
  OBMetricBuToGuRatio,
};

typedef NS_ENUM(NSInteger, OBMaltAdditionMetric) {
  OBMaltAdditionMetricWeight,
  OBMaltAdditionMetricPercentOfGravity
};

@interface OBBrewery : NSManagedObject

@property (nonatomic, retain) NSNumber *mashEfficiency;
@property (nonatomic, retain) NSNumber *defaultBatchSize;

// OBMaltAdditionMetric which corresponds to what type of metric to display for
// each malt addition on the right hand of the OBMaltAdditionViewController
@property (nonatomic, strong) NSNumber *maltAdditionDisplayMetric;

// OBGaugeMetric which corresponds to what metric should be displayed at the
// top of the screen in the OBMaltAdditionViewController
@property (nonatomic, strong) NSNumber *maltGaugeDisplayMetric;

@end

@interface OBBrewery (CoreDataGeneratedAccessors)

+ (OBBrewery *)breweryFromContext:(NSManagedObjectContext *)ctx;

@end
