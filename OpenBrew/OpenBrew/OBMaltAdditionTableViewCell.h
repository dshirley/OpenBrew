//
//  OBMaltAdditionTableViewCell.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/9/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBMaltAdditionTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *maltVariety;
@property (nonatomic, weak) IBOutlet UILabel *quantity;
@property (nonatomic, weak) IBOutlet UILabel *color;
@end
