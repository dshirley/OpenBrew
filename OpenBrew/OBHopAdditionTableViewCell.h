//
//  OBHopAdditionTableViewCell.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/2/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBHopAddition.h"

@interface OBHopAdditionTableViewCell : UITableViewCell

@property (nonatomic) IBOutlet UILabel *hopVariety;
@property (nonatomic) IBOutlet UILabel *alphaAcid;
@property (nonatomic) IBOutlet UILabel *primaryMetric;
@property (nonatomic) IBOutlet UILabel *boilTime;
@property (nonatomic) IBOutlet UILabel *boilUnits;
@property (nonatomic) IBOutlet UIImageView *hopTypeImageView;

- (void)setHopType:(OBHopType)hopType;

@end
