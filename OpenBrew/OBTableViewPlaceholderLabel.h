//
//  OBTableViewPlaceholderLabel.h
//  OpenBrew
//
//  Created by David Shirley 2 on 9/7/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

// This class provides a standard look and feel for the label that is used
// to let users know that no data exists for the current table view.
@interface OBTableViewPlaceholderLabel : UILabel

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text;

@end
