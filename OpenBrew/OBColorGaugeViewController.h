//
//  OBColorGaugeViewController.h
//  OpenBrew
//
//  Created by David Shirley 2 on 10/10/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBColorGaugeViewController : UIViewController

@property (nonatomic) id target;
@property (nonatomic) NSString *key;

- (instancetype)initWithTarget:(id)target
                  keyToDisplay:(NSString *)key;

- (void)refresh:(BOOL)animate;

@end
