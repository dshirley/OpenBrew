//
//  OBPopupView.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/27/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBPopupView;

@interface OBPopupView : UIView

- (id)initWithFrame:(CGRect)frame
     andContentView:(UIView *)view
  andNavigationItem:(UINavigationItem *)navItem;

- (void)popupContent;
- (void)dismissContent;

@end
