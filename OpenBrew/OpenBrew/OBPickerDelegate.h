//
//  OBPickerDelegate.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/5/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OBPickerDelegate <NSObject>
- (void)updateSelectionForPicker:(UIPickerView *)picker;
@end
