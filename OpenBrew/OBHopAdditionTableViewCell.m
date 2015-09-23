//
//  OBHopAdditionTableViewCell.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/2/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopAdditionTableViewCell.h"

@implementation OBHopAdditionTableViewCell

- (void)setHopType:(OBHopType)hopType
{
  if (OBHopTypePellet == hopType) {
    self.hopTypeImageView.image = [UIImage imageNamed:@"HopPellet"];
  } else if (OBHopTypeWhole == hopType) {
    self.hopTypeImageView.image = [UIImage imageNamed:@"WholeConeHop"];
  } else {
    NSAssert(NO, @"Invalid hop type");
  }
}

@end
