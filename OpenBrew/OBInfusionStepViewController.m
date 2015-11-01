//
//  OBInfusionStepViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 10/2/15.
//  Copyright © 2015 OpenBrew. All rights reserved.
//

#import "OBInfusionStepViewController.h"
#import "OBKvoUtils.h"
#import "OBMashCalculationTableViewCell.h"
#import "OBInfusionStepTableViewDelegate.h"

// Google Analytics constants
static NSString* const OBGAScreenName = @"Mash Infusion";

@interface OBInfusionStepViewController()
@property (nonatomic) OBInfusionStepTableViewDelegate *tableViewDelegate;
@property (nonatomic) OBNumericGaugeViewController *gaugeViewController;
@property (nonatomic) IBOutlet UIView *gauge;
@end

@implementation OBInfusionStepViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.screenName = OBGAScreenName;
  self.navigationItem.title = @"Mash Infusion";

  self.tableViewDelegate = [[OBInfusionStepTableViewDelegate alloc] initWithGACategory:OBGAScreenName];

  self.gaugeViewController = [[OBNumericGaugeViewController alloc] initWithTarget:self
                                                                     keyToDisplay:KVO_KEY(infusionWaterVolume)
                                                                      valueFormat:@"%.1f"
                                                                  descriptionText:@"Infusion water (quarts)"];

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

- (void)setTableViewDelegate:(OBInfusionStepTableViewDelegate *)tableViewDelegate
{
  [_tableViewDelegate removeObserver:self forKeyPath:KVO_KEY(grainWeightInPounds)];
  [_tableViewDelegate removeObserver:self forKeyPath:KVO_KEY(waterVolumeInGallons)];
  [_tableViewDelegate removeObserver:self forKeyPath:KVO_KEY(currentTemperatureInFahrenheit)];
  [_tableViewDelegate removeObserver:self forKeyPath:KVO_KEY(waterTemperatureInFahrenheit)];
  [_tableViewDelegate removeObserver:self forKeyPath:KVO_KEY(targetTemperatureInFahrenheit)];

  _tableViewDelegate = tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;
  self.tableView.delegate = self.tableViewDelegate;

  [_tableViewDelegate addObserver:self forKeyPath:KVO_KEY(grainWeightInPounds) options:0 context:nil];
  [_tableViewDelegate addObserver:self forKeyPath:KVO_KEY(waterVolumeInGallons) options:0 context:nil];
  [_tableViewDelegate addObserver:self forKeyPath:KVO_KEY(currentTemperatureInFahrenheit) options:0 context:nil];
  [_tableViewDelegate addObserver:self forKeyPath:KVO_KEY(waterTemperatureInFahrenheit) options:0 context:nil];
  [_tableViewDelegate addObserver:self forKeyPath:KVO_KEY(targetTemperatureInFahrenheit) options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
  [self willChangeValueForKey:KVO_KEY(infusionWaterVolume)];
  [self didChangeValueForKey:KVO_KEY(infusionWaterVolume)];
  [self.tableView reloadData];
}

// http://howtobrew.com/book/section-3/the-methods-of-mashing/calculations-for-boiling-water-additions
// Wa = (T2 - T1)(.2G + Wm)/(Tw - T2)
- (float)infusionWaterVolume
{
  float grainWeight = [self.tableViewDelegate.grainWeightInPounds floatValue];
  float waterVolumeInQuarts = [self.tableViewDelegate.waterVolumeInGallons floatValue] * 4;

  float t1 = [self.tableViewDelegate.currentTemperatureInFahrenheit floatValue];
  float t2 = [self.tableViewDelegate.targetTemperatureInFahrenheit floatValue];
  float tW = [self.tableViewDelegate.waterTemperatureInFahrenheit floatValue];

  return (t2 - t1) * ((.2 * grainWeight) + waterVolumeInQuarts) / (tW - t2);
}

@end
