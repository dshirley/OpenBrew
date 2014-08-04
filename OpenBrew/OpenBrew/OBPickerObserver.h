//
//  OBPickerObserver.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OBPickerObserver <NSObject>
- (void)pickerChanged;
@end
