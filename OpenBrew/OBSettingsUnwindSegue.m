//
//  OBSettingsUnwindSegue.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBSettingsUnwindSegue.h"
#import "OBBaseSettingsViewController.h"

@implementation OBSettingsUnwindSegue

- (void)perform
{
  OBBaseSettingsViewController *settingsVc = (id)self.sourceViewController;

  UIBarButtonItem *savedAddButton = self.destinationViewController.navigationItem.rightBarButtonItem;
  self.destinationViewController.navigationItem.rightBarButtonItem = settingsVc.navigationBar.topItem.rightBarButtonItem;

  // Use hide rather than remove from superview. Removing the view causes the
  // settingsView to "jump up" due to some issues with the constraints.
  settingsVc.navigationBar.hidden = YES;

  [self.destinationViewController.navigationItem setHidesBackButton:NO animated:YES];
  [self.destinationViewController.navigationItem setRightBarButtonItem:savedAddButton animated:YES];

  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:0
                   animations:^{

                     CGRect settingsFrame = settingsVc.settingsView.frame;
                     settingsVc.settingsView.frame = CGRectOffset(settingsFrame, 0,
                                                                  settingsFrame.size.height);

                     settingsVc.greyoutView.backgroundColor = [UIColor clearColor];
                   }
                   completion:^(BOOL finished) {
                     [self.sourceViewController dismissViewControllerAnimated:NO
                                                                   completion:NULL];
                   }];
}

@end
