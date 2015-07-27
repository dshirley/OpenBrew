//
//  OBMaltAdditionSettingsUnwindSegue.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/26/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionSettingsUnwindSegue.h"
#import "OBMaltAdditionViewController.h"
#import "OBMaltAdditionSettingsViewController.h"

@implementation OBMaltAdditionSettingsUnwindSegue

- (void)perform
{
  OBMaltAdditionSettingsViewController *settingsVc = (id)self.sourceViewController;
  OBMaltAdditionViewController *maltsVc = (id)self.destinationViewController;

  UIBarButtonItem *savedAddButton = maltsVc.navigationItem.rightBarButtonItem;
  maltsVc.navigationItem.rightBarButtonItem = settingsVc.navigationBar.topItem.rightBarButtonItem;

  // Use hide rather than remove from superview. Removing the view causes the
  // settingsView to "jump up" due to some issues with the constraints.
  settingsVc.navigationBar.hidden = YES;

  [maltsVc.navigationItem setHidesBackButton:NO animated:YES];
  [maltsVc.navigationItem setRightBarButtonItem:savedAddButton animated:YES];

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
