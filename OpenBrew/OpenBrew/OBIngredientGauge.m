//
//  OBInstrumentGauge.m
//  OpenBrew
//
//  Created by David Shirley 2 on 2/7/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBIngredientGauge.h"
#import "OBColorView.h"

#define VALUE_HEIGHT 90
#define VALUE_FONT_SIZE 64

#define DESCRIPTION_Y (VALUE_HEIGHT - 10)
#define DESCRIPTION_HEIGHT 20

@interface OBIngredientGauge()
@property (weak, nonatomic) IBOutlet OBColorView *colorView;
@end


@implementation OBIngredientGauge

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  
  if (self) {
    [self doInit];
  }
  
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  
  if (self) {
    [self doInit];
  }
  
  return self;
}

- (void)doInit
{
  UIView *view = [[NSBundle mainBundle] loadNibNamed:@"OBIngredientGauge" owner:self options:nil][0];
  view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
  [self addSubview:view];
}

- (void)setColorInSrm:(uint32_t)srm
{
  self.colorView.colorInSrm = srm;
}

- (uint32_t)colorInSrm
{
  return self.colorView.colorInSrm;
}

@end
