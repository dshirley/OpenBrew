//
//  OBHopAdditionTableViewCell.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/2/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBHopAdditionTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *hopVariety;
@property (nonatomic, weak) IBOutlet UILabel *alphaAcid;
@property (nonatomic, weak) IBOutlet UILabel *quantity;
@property (nonatomic, weak) IBOutlet UILabel *boilTime;
@property (nonatomic, weak) IBOutlet UILabel *boilUnits;
@end
