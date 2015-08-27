//
//  OBYeastTableViewCell.m
//  OpenBrew
//
//  Created by David Shirley 2 on 6/25/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import "OBYeastTableViewCell.h"

@implementation OBYeastTableViewCell

- (void)setSelected:(BOOL)selected
{
  [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  if (selected) {
    [self setAccessoryType:UITableViewCellAccessoryCheckmark];
  } else {
    [self setAccessoryType:UITableViewCellAccessoryNone];
  }
}



@end
