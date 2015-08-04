//
//  OBHopAdditionSettingsSegue.m
//  OpenBrew
//
//  Created by David Shirley 2 on 8/3/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBHopAdditionSettingsSegue.h"
#import "OBHopAdditionViewController.h"
#import "OBHopAdditionSettingsViewController.h"

@implementation OBHopAdditionSettingsSegue

- (void)perform
{
  OBHopAdditionSettingsViewController *settingsVc = (id)self.destinationViewController;
  OBHopAdditionViewController *hopsVc = (id)self.sourceViewController;

  settingsVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;

  // This line is required in order for the IBOutlets to get setup for the settingsVc
  // Wow - that was super painful to debug
  [hopsVc.view addSubview:settingsVc.view];

  // The unwind segue will add this back
  [hopsVc.navigationItem setHidesBackButton:YES animated:YES];

  UIBarButtonItem *origItem = hopsVc.navigationItem.rightBarButtonItem;
  UIBarButtonItem *doneItem = settingsVc.navigationBar.topItem.rightBarButtonItem;
  [hopsVc.navigationItem setRightBarButtonItem:doneItem animated:YES];

  UIColor *originGreyoutColor = settingsVc.greyoutView.backgroundColor;
  settingsVc.greyoutView.backgroundColor = [UIColor clearColor];
  [hopsVc.view bringSubviewToFront:settingsVc.greyoutView];

  CGRect origSettingsFrame = settingsVc.settingsView.frame;
  settingsVc.settingsView.frame = CGRectOffset(origSettingsFrame, 0, origSettingsFrame.size.height);
  [hopsVc.view bringSubviewToFront:settingsVc.settingsView];

  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:0
                   animations:^{
                     settingsVc.settingsView.frame = origSettingsFrame;
                     settingsVc.greyoutView.backgroundColor = originGreyoutColor;
                   }
                   completion:^(BOOL finished) {
                     [hopsVc presentViewController:settingsVc animated:NO completion:nil];
                     [hopsVc.navigationItem setRightBarButtonItem:origItem animated:YES];
                   }];
}

@end
