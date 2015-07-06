//
//  OBYeastTableViewCell.h
//  OpenBrew
//
//  Created by David Shirley 2 on 6/25/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBYeastTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *yeastName;
@property (weak, nonatomic) IBOutlet UILabel *yeastIdentifier;
@end
