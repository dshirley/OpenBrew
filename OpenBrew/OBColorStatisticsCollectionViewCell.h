//
//  OBColorStatisticsCollectionViewCell.h
//  OpenBrew
//
//  Created by David Shirley 2 on 6/20/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBColorView.h"

@interface OBColorStatisticsCollectionViewCell : UICollectionViewCell
@property (nonatomic) IBOutlet OBColorView *colorView;
@property (nonatomic) IBOutlet UILabel *descriptionLabel;
@end
