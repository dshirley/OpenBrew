//
//  OBPopupView.h
//  OpenBrew
//
//  Created by David Shirley 2 on 8/27/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBPopupView;
@protocol OBPopupViewDelegate;


@interface OBPopupView : UIView

@property (nonatomic, weak) id <OBPopupViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
     andContentView:(UIView *)view;

- (void)popupContent;
- (void)dismissContent;

@end

@protocol OBPopupViewDelegate <NSObject>

- (void)popupViewWasDismissed:(OBPopupView *)popupView;

@end