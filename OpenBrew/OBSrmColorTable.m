//
//  OBSrmColorTable.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/30/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBSrmColorTable.h"

uint32_t colorMapping[] = { 0xFFFFFF, 0xF3F993, 0xF5F75C, 0xF6F513, 0xEAE615, 0xE0D01B, 0xD5BC26, 0xCDAA37, 0xC1963C, 0xBE8C3A, 0xBE823A, 0xC17A37, 0xBF7138, 0xBC6733, 0xB26033, 0xA85839, 0x985336, 0x8D4C32, 0x7C452D, 0x6B3A1E, 0x5D341A, 0x4E2A0C, 0x4A2727, 0x361F1B, 0x261716, 0x231716, 0x19100F, 0x16100F, 0x120D0C, 0x100B0A, 0x050B0A };

// Credit: http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
UIColor *colorForHex(uint32_t hex)
{
  CGFloat red = ((float) ((hex & 0xFF0000) >> 16)) / 255.0;
  CGFloat green = ((float) ((hex & 0xFF00) >> 8)) / 255.0;
  CGFloat blue = ((float) (hex & 0xFF)) / 255.0;
  return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

UIColor *colorForSrm(uint32_t srm)
{
  if (srm >= (sizeof(colorMapping) / sizeof(uint32_t))) {
    return [UIColor blackColor];
  } else if (srm == 0) {
    return [UIColor clearColor];
  }

  return colorForHex(colorMapping[srm]);
}

