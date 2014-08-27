//
//  OBHopAdditionViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 7/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBHopAdditionViewController.h"
#import "OBIngredientGauge.h"
#import "OBIngredientFinderViewController.h"
#import "OBRecipe.h"
#import "OBHops.h"
#import "OBHopAddition.h"
#import "OBHopAdditionTableViewDelegate.h"
#import "OBPickerDelegate.h"
#import <math.h>
#import "OBKvoUtils.h"

// What hop related metric the gauge should display.  These values should
// correspond to the indices of the segements in HopAdditionDisplaySettings.xib
typedef NS_ENUM(NSInteger, OBHopGaugeMetric) {
  OBHopGaugeMetricIBU,
  OBHopGaugeMetricBitteringToGravityRatio
};

@interface OBHopAdditionViewController ()

// Elements from MaltAdditionDisplaySettings.xib
@property (strong, nonatomic) IBOutlet UIView *displaySettingsView;
@property (nonatomic, assign) BOOL settingsViewIsShowing;
@property (nonatomic, strong) UIBarButtonItem *displaySettingsDoneButton;

@property (weak, nonatomic) IBOutlet UIView *blackoutView;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) OBHopGaugeMetric gaugeMetric;
@property (nonatomic, strong) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, strong) OBHopAdditionTableViewDelegate *tableViewDelegate;
@end

@implementation OBHopAdditionViewController

- (void)awakeFromNib {
  [super awakeFromNib];
}

- (void)loadView {
  [super loadView];

  self.tableViewDelegate = [[OBHopAdditionTableViewDelegate alloc] initWithRecipe:self.recipe andTableView:self.tableView];
  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  self.navigationItem.rightBarButtonItem = self.editButtonItem;

  [self addHopDisplaySettingsView];

  // We can hide the view either here or in storyboard.
  // If it was done in storyboard, it would grey out the whole view, which is confusing.
  // This needs to be done because grey boxes pop up in weird places otherwise.
  [self.blackoutView setHidden:YES];

  self.displaySettingsDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(dismissSettingsView)];

  [self reload];
}


#pragma mark Display Settings View Logic

// Create the settings view and place it below the visible screen.  This view
// will pop up/down to allow users to display different malt metrics
- (void)addHopDisplaySettingsView
{
  UIView *subview =  [[[NSBundle mainBundle] loadNibNamed:@"HopAdditionDisplaySettings"
                                                    owner:self
                                                  options:nil] objectAtIndex:0];

  assert(subview == self.displaySettingsView);

  subview.frame = [self settingsViewHiddenFrame];

  [self.view addSubview:subview];

  self.settingsViewIsShowing = NO;
}

- (CGRect)settingsViewVisibleFrame
{
  CGRect hiddenFrame = [self settingsViewHiddenFrame];

  return CGRectMake(hiddenFrame.origin.x, hiddenFrame.origin.y - hiddenFrame.size.height,
                    hiddenFrame.size.width, hiddenFrame.size.height);
}

- (CGRect)settingsViewHiddenFrame
{
  CGRect myFrame = self.view.frame;

  return CGRectMake(myFrame.origin.x, myFrame.origin.y + myFrame.size.height,
                    myFrame.size.width, self.displaySettingsView.frame.size.height);
}

- (IBAction)showSettingsView:(UIBarButtonItem *)sender
{
  [self.view bringSubviewToFront:self.blackoutView];
  [self.view bringSubviewToFront:self.displaySettingsView];
  [self.blackoutView setHidden:NO];

  [self.navigationItem setHidesBackButton:YES animated:YES];
  [self.navigationItem setRightBarButtonItem:self.displaySettingsDoneButton animated:YES];

  self.settingsViewIsShowing = YES;

  [UIView animateWithDuration:0.5
                   animations:^{
                     self.displaySettingsView.frame = [self settingsViewVisibleFrame];
                   }];
}

- (IBAction)dismissSettingsView {
  [self.blackoutView setHidden:YES];
  [self.view sendSubviewToBack:self.blackoutView];

  [self.navigationItem setHidesBackButton:NO animated:YES];
  self.navigationItem.rightBarButtonItem = self.editButtonItem;

  self.settingsViewIsShowing = NO;

  [UIView animateWithDuration:0.5
                   animations:^{
                     self.displaySettingsView.frame = [self settingsViewHiddenFrame];
                   }];
}


- (void)reload {
  [self.tableView reloadData];
  [self refreshGauge];
}

- (void)refreshGauge
{
  if (self.gaugeMetric == OBHopGaugeMetricIBU) {
    float ibu = [self.recipe IBUs];
    _gauge.value.text = [NSString stringWithFormat:@"%d", (int) round(ibu)];
    _gauge.description.text = @"IBUs";
  } else if (self.gaugeMetric == OBHopGaugeMetricBitteringToGravityRatio) {
    float buToGuRatio = [self.recipe bitternessToGravityRatio];
    _gauge.value.text = [NSString stringWithFormat:@"%.2f", buToGuRatio];
    _gauge.description.text = @"Bitterness to Gravity Ratio";
  } else {
    [NSException raise:@"Bad OBHopGaugeMetric" format:@"Metric: %ld", self.gaugeMetric];
  }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
  [super setEditing:editing animated:animated];

  // Get rid of the picker.  It'll get in the way and we don't want users to
  // be able to move it anyways.
  [self.tableView beginUpdates];
  [self.tableViewDelegate closeDrawerForTableView:self.tableView];
  [self.tableView endUpdates];

  [self.tableView setEditing:editing animated:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:KVO_KEY(IBUs)]) {
    [self refreshGauge];
  }
}

- (void)setRecipe:(OBRecipe *)recipe
{
  [_recipe removeObserver:self forKeyPath:KVO_KEY(IBUs)];

  _recipe = recipe;

  [_recipe addObserver:self forKeyPath:KVO_KEY(IBUs) options:0 context:nil];
}

- (void)dealloc
{
  self.recipe = nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"addHops"]) {

    OBIngredientFinderViewController *next = [segue destinationViewController];

    NSManagedObjectContext *moc = self.recipe.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Hops"
                                              inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];

    [request setSortDescriptors:@[sortDescriptor]];

    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];

    assert(array);

    [next setIngredients:array];
  }
}

// TODO: duplicate code except with hops instead of malts... not too egregious, though
- (void)ingredientSelected:(UIStoryboardSegue *)unwindSegue
{
  if ([[unwindSegue identifier] isEqualToString:@"IngredientSelected"]) {
    OBIngredientFinderViewController *finderView = [unwindSegue sourceViewController];
    OBHops *hopVariety = [finderView selectedIngredient];
    OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:hopVariety
                                                                 andRecipe:self.recipe];

    NSUInteger numberOfHops = [[self.recipe hopAdditions] count];

    hopAddition.displayOrder = [NSNumber numberWithUnsignedInteger:numberOfHops];

    [self.recipe addHopAdditionsObject:hopAddition];

    [self.recipe.managedObjectContext save:nil];
    [self reload];
  }
}


#pragma mark - MaltAdditionDisplaySettings

// Linked to MaltAdditionDisplaySettings.xib.  This method gets called when a
// UISegment is selected. This method changes the value that is displayed for
// the gauge.
- (IBAction)gaugeDisplaySettingsChanged:(UISegmentedControl *)sender
{
  self.gaugeMetric = sender.selectedSegmentIndex;
  [self refreshGauge];
}

// Linked to MaltAdditionDisplaySettings.xib.  This method gets called when a
// UISegment is selected that changes the information displayed for each malt
// line item.
- (IBAction)ingredientDisplaySettingsChanged:(UISegmentedControl *)sender
{
//  // Note that the segment indices must allign with the metric enum
//  OBMaltAdditionMetric newMetric = sender.selectedSegmentIndex;
//  self.tableViewDelegate.maltAdditionMetricToDisplay = newMetric;
}

@end
