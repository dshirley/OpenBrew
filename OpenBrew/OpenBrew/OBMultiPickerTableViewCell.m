//
//  OBMultiPickerTableViewCell.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/1/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMultiPickerTableViewCell.h"

#define SEGMENT_HEIGHT 35

@implementation OBMultiPickerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)awakeFromNib
{
  [self rotateSegmentController];
}

- (void)rotateSegmentController
{
  // Rotate the whole segment controller
  self.selector.transform = CGAffineTransformMakeRotation(M_PI / 2.0);

  // Set the width of each segment.  Since we've rotated, the widths are now the heights
  for (int i = 0; i < [self.selector numberOfSegments]; i++) {
    [self.selector setWidth:35 forSegmentAtIndex:i];
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

- (CGFloat)segmentControllerX
{
  CGFloat segmentControllerHeight = (self.selector.numberOfSegments * SEGMENT_HEIGHT);

  return (self.frame.size.height - segmentControllerHeight) / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
