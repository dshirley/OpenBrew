//
//  OBMaltAdditionSettingsUnwindSegue.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionSettingsUnwindSegue.h"

@implementation OBMaltAdditionSettingsUnwindSegue

- (void)perform {
   [self.sourceViewController dismissViewControllerAnimated:NO completion:NULL];
}

@end
