//
//  OBHopBoilTimePickerDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/4/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBHopAddition;
@protocol OBPickerObserver;

@interface OBHopBoilTimePickerDelegate : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) OBHopAddition *hopAddition;
@property (nonatomic, weak) id<OBPickerObserver> pickerObserver;

- (id)initWithHopAddition:(OBHopAddition *)hopAddition
              andObserver:(id)updateObserver;

+ (NSInteger)rowForValue:(float)boilTimeInMinutes;
+ (float)valueForRow:(NSInteger)row;

@end
