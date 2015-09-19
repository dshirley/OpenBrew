//
//  OBSettings.h
//  OpenBrew
//
//  Created by David Shirley 2 on 1/25/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OBYeast.h"

// TODO: should this be moved to the gauge controller?
typedef NS_ENUM(NSInteger, OBGaugeMetric) {
  OBMetricOriginalGravity,
  OBMetricFinalGravity,
  OBMetricAbv,
  OBMetricColor,
  OBMetricIbu,
  OBMetricBuToGuRatio,
  OBMetricNumberOfMetrics
};

typedef NS_ENUM(NSInteger, OBMaltAdditionMetric) {
  OBMaltAdditionMetricWeight,
  OBMaltAdditionMetricPercentOfGravity
};

typedef NS_ENUM(NSInteger, OBHopAdditionMetric) {
  OBHopAdditionMetricWeight,
  OBHopAdditionMetricIbu
};

@interface OBSettings : NSManagedObject

// Some starter data is provided with each app. The data is copied into the app at
// the beginning of the first session for each version of the app. Once the data is
// copied, this field is updated and the data is not copied again.
@property (nonatomic) NSString *copiedStarterDataVersion;

@property (nonatomic) NSNumber *defaultMashEfficiency;

@property (nonatomic) NSNumber *defaultPostBoilSize;

@property (nonatomic) NSNumber *defaultPreBoilSize;

// OBMaltAdditionMetric which corresponds to what type of metric to display for
// each malt addition on the right hand of the OBMaltAdditionViewController
@property (nonatomic) NSNumber *maltAdditionDisplayMetric;

// OBGaugeMetric to display for the gauge of the OBMaltAdditionViewController
@property (nonatomic) NSNumber *maltGaugeDisplayMetric;

// An OBHopAdditionMetric describes what to display for each cell of the OBHopAdditionViewController
@property (nonatomic) NSNumber *hopAdditionDisplayMetric;

// OBGaugeMetric to display for the gauge of the OBHopAdditionViewController
@property (nonatomic) NSNumber *hopGaugeDisplayMetric;

// OBYeastManufacturer selected in the OBYeastAdditionViewController
@property (nonatomic) NSNumber *selectedYeastManufacturer;

@property (nonatomic) NSNumber *ibuFormula;

@end
