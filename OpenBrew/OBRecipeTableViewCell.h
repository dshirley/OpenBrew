//
//  OBRecipeTableViewCell.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/1/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBColorView.h"

@interface OBRecipeTableViewCell : UITableViewCell
@property (nonatomic) IBOutlet OBColorView *colorView;
@property (nonatomic) IBOutlet UILabel *recipeName;
@end
