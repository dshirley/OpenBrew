//
//  OBAlphaAcidPickerDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/2/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBHopAddition;
@protocol OBPickerObserver;

@interface OBAlphaAcidPickerDelegate : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) OBHopAddition *hopAddition;
@property (nonatomic, weak) id<OBPickerObserver> pickerObserver;

- (id)initWithHopAddition:(OBHopAddition *)hopAddition andObserver:(id)updateObserver;

+ (NSInteger)rowForAlphaAcidPercent:(float)alphaAcidPercent;
+ (float)alphaAcidPercentForRow:(NSInteger)row;

@end
