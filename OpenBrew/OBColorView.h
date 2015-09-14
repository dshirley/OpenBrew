//
//  OBColorView.h
//  OpenBrew
//
//  Created by David Shirley 2 on 6/20/15.
//  Copyright (c) 2015 OpenBrew. All rights reserved.
//
//  This class represents the beer color swatch that is located in the
//  OBRecipeViewController. It's purpose in life is to display a color.

#import <UIKit/UIKit.h>

@interface OBColorView : UIView

// The color of the beer as measured in SRM
@property (nonatomic, assign) uint32_t colorInSrm;

@end
