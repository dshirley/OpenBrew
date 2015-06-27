//
//  OBMultiPickerTableViewCell.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/1/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMultiPickerTableViewCell.h"

// The segment control should be about 1/2 the width of the picker
#define PICKER_WIDTH_PCT (0.60)
#define SEGMENT_WIDTH_PCT (0.30)
#define MARGIN_WIDTH_PCT ((1.0 - PICKER_WIDTH_PCT - SEGMENT_WIDTH_PCT) / 2.0)


// Apple recommends 44 points as a minimum size for buttons
// Originally the code was using the height of a segmented control.  This felt
// a bit cramped on my iPhone 5s.
#define SEGMENT_HEIGHT 44

@interface OBMultiPickerTableViewCell()
@property (nonatomic, assign) CGFloat origSegmentHeight;
@end

@implementation OBMultiPickerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)awakeFromNib
{
  // Add a single segment in order to obtain the default segment height.
  // This is removed below
  self.selector = [[UISegmentedControl alloc] initWithItems:@[ @"dummy" ]];
  self.picker = [[UIPickerView alloc] init];

  self.origSegmentHeight = 44;//self.selector.frame.size.height * 2;
  [self.selector removeAllSegments];

  [self.contentView addSubview:self.selector];
  [self.contentView addSubview:self.picker];
}


- (void)layoutSubviews
{
  [super layoutSubviews];
  [self rotateSegmentController];
  
  // There's two slivers of deadspace:
  //   1) between the left edge the segment control
  //   2) between the segment control and the picker
  CGFloat marginWidth = self.contentView.frame.size.width * MARGIN_WIDTH_PCT;

  // Layout the segment selector.  Warning: this is confusing.  The height and width are reversed
  // because we rotated the segment selector by 90 degrees.
  CGFloat selectorHeight = self.contentView.frame.size.width * SEGMENT_WIDTH_PCT;
  CGFloat selectorWidth = self.origSegmentHeight * self.selector.numberOfSegments;
  CGRect selectorFrame = CGRectMake(marginWidth,
                                    (self.contentView.frame.size.height - selectorWidth) / 2,
                                    selectorHeight,
                                    selectorWidth);

  CGRect pickerFrame = CGRectMake(self.contentView.frame.size.width * (1.0 - PICKER_WIDTH_PCT),
                                  0,
                                  self.contentView.frame.size.width * PICKER_WIDTH_PCT,
                                  self.picker.frame.size.height);

  // At this point we have the frames for both the picker and the segment control.
  // If the segment control doesn't have any entries, we want the picker to take
  // up the whole cell.

  if (self.selector.numberOfSegments > 0) {
    [self.selector setFrame:selectorFrame];
    [self.picker setFrame:pickerFrame];
  } else {
    [self.selector removeFromSuperview];

    // Expand the width of the picker to encompass the X position of where we had
    // planned to put the picker.
    pickerFrame.size.width += pickerFrame.origin.x - selectorFrame.origin.x;
    pickerFrame.origin.x = selectorFrame.origin.x;
  }

  [self.selector setNeedsLayout];
  [self.picker setNeedsLayout];
}

- (void)rotateSegmentController
{
  // Rotate the whole segment controller
  self.selector.transform = CGAffineTransformMakeRotation(M_PI / 2.0);

  // Set the width of each segment.  Since we've rotated, the widths are now the heights
  for (int i = 0; i < [self.selector numberOfSegments]; i++) {
    [self.selector setWidth:self.origSegmentHeight forSegmentAtIndex:i];
  }

  // Rotate each segment label so that they read horizontally again
  NSArray *segments = [self.selector subviews];

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setSegments:(NSArray *)segmentTitles
{
  [self.selector removeAllSegments];

  for (int i = 0; i < segmentTitles.count; i++) {
    [self.selector insertSegmentWithTitle:segmentTitles[i] atIndex:i animated:NO];
  }

  [self.selector setSelectedSegmentIndex:0];
  [self setNeedsLayout];
}

@end
