//
//  OBMaltAdditionSettingsSegue.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionSettingsSegue.h"
#import "OBMaltAdditionViewController.h"
#import "OBMaltAdditionSettingsViewController.h"

@implementation OBMaltAdditionSettingsSegue

- (void)perform
{
  OBMaltAdditionSettingsViewController *settingsVc = (id)self.destinationViewController;
  OBMaltAdditionViewController *maltsVc = (id)self.sourceViewController;

  settingsVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;

  [maltsVc presentViewController:settingsVc animated:NO completion:nil];
}

@end
