//
//  OBMashCalculationsViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/2/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBMashCalculationsViewController.h"
#import "OBKvoUtils.h"
#import "OBMashCalculationTableViewCell.h"
#import "OBMashCalculationsTableViewDelegate.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Mash Calculations";

@interface OBMashCalculationsViewController()
@property (nonatomic) OBMashCalculationsTableViewDelegate *tableViewDelegate;
@property (nonatomic) OBNumericGaugeViewController *gaugeViewController;
@property (nonatomic) IBOutlet UIView *gauge;
@end

@implementation OBMashCalculationsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.screenName = OBGAScreenName;

  self.tableViewDelegate = [[OBMashCalculationsTableViewDelegate alloc] initWithCells:@[ @(OBGrainWeight),
                                                                                         @(OBGrainTemperature),
                                                                                         @(OBWaterVolume),
                                                                                         @(OBTargetTemerature)]
                                                                           gaCategory:OBGAScreenName];

  self.gaugeViewController = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                     keyToDisplay:KVO_KEY(strikeWaterTemperature)
                                                                      valueFormat:@"%.0f°"
                                                                  descriptionText:@"Strike water temperature"];

  [self addChildViewController:self.gaugeViewController];

  self.gaugeViewController.view.frame = CGRectMake(0, 0, self.gauge.bounds.size.width, self.gauge.bounds.size.height);
  [self.gauge addSubview:self.gaugeViewController.view];
  [self.gaugeViewController didMoveToParentViewController:self];

  [self.gaugeViewController refresh:NO];

  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)dealloc
{
  self.tableViewDelegate = nil;
}

- (void)setTableViewDelegate:(OBMashCalculationsTableViewDelegate *)tableViewDelegate
{
  [_tableViewDelegate removeObserver:self forKeyPath:KVO_KEY(grainWeightInPounds)];
  [_tableViewDelegate removeObserver:self forKeyPath:KVO_KEY(grainTemperatureInFahrenheit)];
  [_tableViewDelegate removeObserver:self forKeyPath:KVO_KEY(waterVolumeInGallons)];
  [_tableViewDelegate removeObserver:self forKeyPath:KVO_KEY(targetTemperatureInFahrenheit)];

  _tableViewDelegate = tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;
  self.tableView.delegate = self.tableViewDelegate;

  [_tableViewDelegate addObserver:self forKeyPath:KVO_KEY(grainWeightInPounds) options:0 context:nil];
  [_tableViewDelegate addObserver:self forKeyPath:KVO_KEY(grainTemperatureInFahrenheit) options:0 context:nil];
  [_tableViewDelegate addObserver:self forKeyPath:KVO_KEY(waterVolumeInGallons) options:0 context:nil];
  [_tableViewDelegate addObserver:self forKeyPath:KVO_KEY(targetTemperatureInFahrenheit) options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
  [self willChangeValueForKey:KVO_KEY(strikeWaterTemperature)];
  [self didChangeValueForKey:KVO_KEY(strikeWaterTemperature)];
  [self.tableView reloadData];
}

// http://howtobrew.com/book/section-3/the-methods-of-mashing/calculations-for-boiling-water-additions
// Strike Water Temperature Tw = (.2/r)(T2 - T1) + T2
- (float)strikeWaterTemperature
{
  float grainWeight = [self.tableViewDelegate.grainWeightInPounds floatValue];
  float liquorVolumeInQuarts = [self.tableViewDelegate.waterVolumeInGallons floatValue] * 4;

  float t1 = [self.tableViewDelegate.grainTemperatureInFahrenheit floatValue];
  float t2 = [self.tableViewDelegate.targetTemperatureInFahrenheit floatValue];
  float r = liquorVolumeInQuarts / grainWeight;

  return ((.2 / r) * (t2 - t1)) + t2;
}

@end
