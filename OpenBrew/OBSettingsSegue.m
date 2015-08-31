//
//  OBSettingsSegue.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBSettingsSegue.h"
#import "OBBaseSettingsViewController.h"

@implementation OBSettingsSegue

- (void)perform
{
  OBBaseSettingsViewController *settingsVc = (OBBaseSettingsViewController *)self.destinationViewController;

  settingsVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;

  // This line is required in order for the IBOutlets to get setup for the settingsVc
  // Wow - that was super painful to debug
  [self.sourceViewController.view addSubview:settingsVc.view];

  // The unwind segue will add this back
  [self.sourceViewController.navigationItem setHidesBackButton:YES animated:YES];

  UIBarButtonItem *origItem = self.sourceViewController.navigationItem.rightBarButtonItem;
  UIBarButtonItem *doneItem = settingsVc.navigationBar.topItem.rightBarButtonItem;
  [self.sourceViewController.navigationItem setRightBarButtonItem:doneItem animated:YES];

  UIColor *originGreyoutColor = settingsVc.greyoutView.backgroundColor;
  settingsVc.greyoutView.backgroundColor = [UIColor clearColor];
  [self.sourceViewController.view bringSubviewToFront:settingsVc.greyoutView];

  CGRect origSettingsFrame = settingsVc.settingsView.frame;
  settingsVc.settingsView.frame = CGRectOffset(origSettingsFrame, 0, origSettingsFrame.size.height);
  [self.sourceViewController.view bringSubviewToFront:settingsVc.settingsView];

  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:0
                   animations:^{
                     settingsVc.settingsView.frame = origSettingsFrame;
                     settingsVc.greyoutView.backgroundColor = originGreyoutColor;
                   }
                   completion:^(BOOL finished) {
                     [self.sourceViewController presentViewController:settingsVc animated:NO completion:nil];
                     [self.sourceViewController.navigationItem setRightBarButtonItem:origItem animated:YES];
                   }];
}

@end
