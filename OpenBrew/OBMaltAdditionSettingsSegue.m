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

//  settingsVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;

  // This line is required in order for the IBOutlets to get setup for the settingsVc
  // Wow - that was super painful to debug
  [maltsVc.view addSubview:settingsVc.view];

  [maltsVc.navigationItem setHidesBackButton:YES animated:YES];

  settingsVc.navigationBar.frame = maltsVc.navigationController.navigationBar.frame;
  [maltsVc.view bringSubviewToFront:settingsVc.navigationBar];

  UIColor *originGreyoutColor = settingsVc.greyoutView.backgroundColor;
  settingsVc.greyoutView.backgroundColor = [UIColor clearColor];
  [maltsVc.view bringSubviewToFront:settingsVc.greyoutView];

  CGRect origSettingsFrame = settingsVc.settingsView.frame;
  settingsVc.settingsView.frame = CGRectOffset(origSettingsFrame, 0, origSettingsFrame.size.height);
  [maltsVc.view bringSubviewToFront:settingsVc.settingsView];

  [UIView animateWithDuration:5.0
                        delay:0.0
                      options:0
                   animations:^{
                     settingsVc.settingsView.frame = origSettingsFrame;
                     settingsVc.greyoutView.backgroundColor = originGreyoutColor;
                   }
                   completion:^(BOOL finished) {
//                     [settingsVc.settingsView removeFromSuperview];
//                     [settingsVc.greyoutView removeFromSuperview];
                     [settingsVc.view removeFromSuperview];
                     settingsVc.greyoutView.backgroundColor = originGreyoutColor;
                     [maltsVc presentViewController:settingsVc animated:NO completion:nil];
                   }];
}

@end
