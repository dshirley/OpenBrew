//
//  OBPickerDelegate.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/2/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBPickerDelegate.h"

typedef struct _OBSequence {
  float start;
  float end;
  float increment;
} OBSequence;

@interface OBPickerDelegate()
@property (nonatomic) id target;
@property (nonatomic) NSString *key;
@property (nonatomic, assign) OBSequence sequence;
@end

@implementation OBPickerDelegate

- (instancetype)initWithTarget:(id)target key:(NSString *)key
{
  self = [super init];

  if (self) {
    self.target = target;
    self.key = key;
    self.format = @"%.0f";
  }

  return self;
}

- (void)from:(float)start to:(float)end incrementBy:(float)increment
{
  OBSequence sequence;

  NSCAssert(start < end, @"Currently only support monotonically increasing sequences");

  sequence.start = start;
  sequence.end = end;
  sequence.increment = increment;

  self.sequence = sequence;
}

- (NSInteger)rowForValue:(float)value
{
  if (value <= self.sequence.start) {
    return 0;
  } else if (value >= self.sequence.end) {
    return [self pickerView:nil numberOfRowsInComponent:0];
  }

  return roundf((value - self.sequence.start) / self.sequence.increment);
}

- (float)valueForRow:(NSInteger)row
{
  return self.sequence.start + (row * self.sequence.increment);
}

- (void)updateSelectionForPicker:(UIPickerView *)picker
{
  float value = [[self.target valueForKey:self.key] floatValue];
  NSInteger row = [self rowForValue:value];
  [picker selectRow:row inComponent:0 animated:NO];
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return (self.sequence.end - self.sequence.start) / self.sequence.increment;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
  float value = [self valueForRow:row];
  return [NSString stringWithFormat:self.format, value];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
  NSNumber *value = @([self valueForRow:row]);
  [self.target setValue:value forKey:self.key];
}

@end

#import "OBKvoUtils.h"

@implementation OBPickerDelegate(OBHopAddition)

+ (OBPickerDelegate *)hopsQuantityInGramsPickerDelegate:(OBHopAddition *)hopAddition
{
  OBPickerDelegate *delegate = [[OBPickerDelegate alloc] initWithTarget:hopAddition key:KVO_KEY(quantityInGrams)];
  delegate.format = @"%.0f g";
  [delegate from:0 to:500 incrementBy:1];
  return delegate;
}

+ (OBPickerDelegate *)hopsQuantityInOuncesPickerDelegate:(OBHopAddition *)hopAddition
{
  OBPickerDelegate *delegate =  [[OBPickerDelegate alloc] initWithTarget:hopAddition key:KVO_KEY(quantityInOunces)];
  delegate.format = @"%.1f oz";
  [delegate from:0 to:16 incrementBy:.1];
  return delegate;
}

+ (OBPickerDelegate *)hopsAlphaAcidPickerDelegate:(OBHopAddition *)hopAddition
{
  OBPickerDelegate *delegate =  [[OBPickerDelegate alloc] initWithTarget:hopAddition key:KVO_KEY(alphaAcidPercent)];
  delegate.format = @"%.1f%%";
  [delegate from:0 to:20 incrementBy:.1];
  return delegate;
}

@end

@implementation OBPickerDelegate(OBRecipe)

+ (OBPickerDelegate *)volumePickerDelegate:(OBRecipe *)recipe key:(NSString *)key;
{
  OBPickerDelegate *delegate =  [[OBPickerDelegate alloc] initWithTarget:recipe key:key];
  delegate.format = @"%.2f";
  [delegate from:0 to:30 incrementBy:.25];
  return delegate;
}

@end
