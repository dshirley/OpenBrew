//
//  OBMultiPickerView.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/3/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBMultiPickerView.h"

// The segment control should be about 1/2 the width of the picker
#define PICKER_WIDTH_PCT (0.60)
#define SEGMENT_WIDTH_PCT (0.30)
#define MARGIN_WIDTH_PCT ((1.0 - PICKER_WIDTH_PCT - SEGMENT_WIDTH_PCT) / 2.0)

// Apple recommends 44 points as a minimum size for buttons
// Originally the code was using the height of a segmented control.  This felt
// a bit cramped on my iPhone 5s.
#define SEGMENT_HEIGHT 44.0

@interface OBMultiPickerView()

// The segmented control allows switching between different pickers
@property (nonatomic) UISegmentedControl* segmentedControl;

@property (nonatomic) UIPickerView *picker;

// There's a delegate for each segment in the segmentedControl
@property (nonatomic) NSMutableArray *pickerDelegates;

@end

@implementation OBMultiPickerView

- (void)awakeFromNib
{
  self.segmentedControl = [[UISegmentedControl alloc] init];
  self.picker = [[UIPickerView alloc] init];
  self.pickerDelegates = [NSMutableArray array];

  [self.segmentedControl addTarget:self
                            action:@selector(segmentSelected)
                  forControlEvents:UIControlEventValueChanged];

  [self addSubview:self.segmentedControl];
  [self addSubview:self.picker];
}

// Triggered programatically
- (void)setSelectedPicker:(NSInteger)pickerIndex
{
  self.segmentedControl.selectedSegmentIndex = pickerIndex;
  [self updatePicker];
}

// Triggered from a UI event
- (void)segmentSelected
{
  [self updatePicker];
  [self.delegate selectedPickerDidChange:self.segmentedControl.selectedSegmentIndex];
}

// Swap out the UIPickerDelegates when a new segment is selected
- (void)updatePicker
{
  NSInteger index = self.segmentedControl.selectedSegmentIndex;
  id<OBPickerDelegate> pickerDelegate = self.pickerDelegates[index];

  self.picker.delegate = pickerDelegate;
  self.picker.dataSource = pickerDelegate;

  [pickerDelegate updateSelectionForPicker:self.picker];

}

- (void)addPickerDelegate:(id<OBPickerDelegate>)pickerDelegate withTitle:(NSString *)title
{
  [self.pickerDelegates addObject:pickerDelegate];
  [self.segmentedControl insertSegmentWithTitle:title atIndex:self.segmentedControl.numberOfSegments animated:NO];
  [self setSelectedPicker:0];
  [self setNeedsLayout];
}

- (void)removeAllPickers
{
  [self.segmentedControl removeAllSegments];
  [self.pickerDelegates removeAllObjects];
}

#pragma mark View Layout Methods

- (void)layoutSubviews
{
  [super layoutSubviews];
  [self rotateSegmentController];

  // There's two slivers of deadspace:
  //   1) between the left edge the segment control
  //   2) between the segment control and the picker
  CGFloat marginWidth = self.frame.size.width * MARGIN_WIDTH_PCT;

  // Layout the segment selector.  Warning: this is confusing.  The height and width are reversed
  // because we rotated the segment selector by 90 degrees.
  CGFloat selectorHeight = self.frame.size.width * SEGMENT_WIDTH_PCT;
  CGFloat selectorWidth = SEGMENT_HEIGHT * self.segmentedControl.numberOfSegments;
  CGRect selectorFrame = CGRectMake(marginWidth,
                                    (self.frame.size.height - selectorWidth) / 2,
                                    selectorHeight,
                                    selectorWidth);

  CGRect pickerFrame = CGRectMake(self.frame.size.width * (1.0 - PICKER_WIDTH_PCT),
                                  0,
                                  self.frame.size.width * PICKER_WIDTH_PCT,
                                  self.picker.frame.size.height);

  // At this point we have the frames for both the picker and the segment control.
  // If the segment control doesn't have any entries, we want the picker to take
  // up the whole cell.

  if (self.segmentedControl.numberOfSegments > 1) {
    [self.segmentedControl setFrame:selectorFrame];
    [self.picker setFrame:pickerFrame];
  } else {
    [self.segmentedControl removeFromSuperview];

    // Expand the width of the picker to encompass the X position of where we had
    // planned to put the picker.
    pickerFrame.size.width += pickerFrame.origin.x - selectorFrame.origin.x;
    pickerFrame.origin.x = selectorFrame.origin.x;
  }

  [self.segmentedControl setNeedsLayout];
  [self.picker setNeedsLayout];
}

- (void)rotateSegmentController
{
  // Rotate the whole segment controller
  self.segmentedControl.transform = CGAffineTransformMakeRotation(M_PI / 2.0);

  // Set the width of each segment.  Since we've rotated, the widths are now the heights
  for (int i = 0; i < [self.segmentedControl numberOfSegments]; i++) {
    [self.segmentedControl setWidth:SEGMENT_HEIGHT forSegmentAtIndex:i];
  }

  // Rotate each segment label so that they read horizontally again
  NSArray *segments = [self.segmentedControl subviews];

  for (int i = 0; i < [segments count]; i++) {
    UIView *v = (UIView *) segments[i];
    NSArray *subarr = [v subviews];

    for (int j = 0; j < [subarr count]; j++) {
      if ([subarr[j] isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel*) subarr[j];
        label.transform = CGAffineTransformMakeRotation(- M_PI / 2.0);
      }
    }
  }
}

@end
