//
//  OBMaltViewController.m
//  OpenBrew
//
//  Created by David Shirley 2 on 1/24/14.
//  Copyright (c) 2014 OpenBrew. All rights reserved.
//

#import "OBMaltAdditionViewController.h"
#import "OBIngredientGauge.h"
#import "OBIngredientFinderViewController.h"
#import "OBRecipe.h"
#import "OBMalt.h"
#import "OBMaltAddition.h"
#import "OBMaltAdditionTableViewDelegate.h"
#import "OBKvoUtils.h"

// TODO: add comments on how the settings view works
// Name variables  more consistently too

// What malt related metric should the gauge display.  These values should
// correspond to the indices of the MaltAdditionDisplaySettings segmentview.
typedef NS_ENUM(NSInteger, OBMaltGaugeMetric) {
  OBMaltGaugeMetricGravity,
  OBMaltGaugeMetricColor
};

// TODO: add comments on how the settings view works
// Name variables  more consistently too

@interface OBMaltAdditionViewController ()

// Elements from MaltAdditionDisplaySettings.xib
@property (strong, nonatomic) IBOutlet UIView *displaySettingsView;
@property (nonatomic, assign) BOOL settingsViewIsShowing;
@property (nonatomic, strong) UIBarButtonItem *displaySettingsDoneButton;

@property (weak, nonatomic) IBOutlet UIView *blackoutView;

@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (assign) NSInteger drawerCellRowHeight;

@property (nonatomic, assign) OBMaltGaugeMetric gaugeMetric;
@property (nonatomic, weak) IBOutlet OBIngredientGauge *gauge;
@property (nonatomic, strong) OBMaltAdditionTableViewDelegate *tableViewDelegate;
@end

@implementation OBMaltAdditionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (void)loadView {
  [super loadView];

  self.tableViewDelegate = [[OBMaltAdditionTableViewDelegate alloc] initWithRecipe:self.recipe andTableView:self.tableView];
  self.tableView.delegate = self.tableViewDelegate;
  self.tableView.dataSource = self.tableViewDelegate;

  [self addMaltDisplaySettingsView];

  self.displaySettingsDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(dismissSettingsView)];

  [self reload];
}

// Create the settings view and place it below the visible screen.  This view
// will pop up/down to allow users to display different malt metrics
- (void)addMaltDisplaySettingsView
{
  UIView *subview =  [[[NSBundle mainBundle] loadNibNamed:@"MaltAdditionDisplaySettings"
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

  [self.navigationItem setHidesBackButton:YES animated:YES];
  [self.navigationItem setRightBarButtonItem:self.displaySettingsDoneButton animated:YES];

  self.settingsViewIsShowing = YES;

  [UIView animateWithDuration:0.5
                   animations:^{
                     self.displaySettingsView.frame = [self settingsViewVisibleFrame];
                   }];
}

- (IBAction)dismissSettingsView {
  [self.view sendSubviewToBack:self.blackoutView];

  [self.navigationItem setHidesBackButton:NO animated:YES];
  self.navigationItem.rightBarButtonItem = self.editButtonItem;

  self.settingsViewIsShowing = NO;

  [UIView animateWithDuration:0.5
                   animations:^{
                     self.displaySettingsView.frame = [self settingsViewHiddenFrame];
                   }];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.navigationItem.rightBarButtonItem = self.editButtonItem;

  [self reload];
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

- (void)reload {
  [self.tableView reloadData];
  [self refreshGauge];
}

- (void)refreshGauge
{
  if (self.gaugeMetric == OBMaltGaugeMetricGravity) {
    float gravity = [self.recipe originalGravity];
    _gauge.value.text = [NSString stringWithFormat:@"%.3f", gravity];
    _gauge.description.text = @"Starting Gravity";
  } else if (self.gaugeMetric == OBMaltGaugeMetricColor) {
    float srm = [self.recipe colorInSRM];
    _gauge.value.text = [NSString stringWithFormat:@"%.0f", srm];
    _gauge.description.text = @"SRM";
  } else {
    [NSException raise:@"Bad OBMaltGaugeMetric" format:@"Metric: %d", self.gaugeMetric];
  }
}

- (void)setRecipe:(OBRecipe *)recipe
{
  [_recipe removeObserver:self forKeyPath:KVO_KEY(originalGravity)];
  _recipe = recipe;
  [_recipe addObserver:self forKeyPath:KVO_KEY(originalGravity) options:0 context:nil];
}

- (void)dealloc
{
  self.recipe = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:KVO_KEY(originalGravity)]) {
    [self refreshGauge];
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"addIngredient"]) {

    OBIngredientFinderViewController *next = [segue destinationViewController];

    NSManagedObjectContext *moc = self.recipe.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Malt"
                                              inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"name" ascending:YES];\

    [request setSortDescriptors:@[sortDescriptor]];

    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];

    assert(array);

    [next setIngredients:array];
  }
}

- (void)ingredientSelected:(UIStoryboardSegue *)unwindSegue
{
  if ([[unwindSegue identifier] isEqualToString:@"IngredientSelected"]) {
    OBIngredientFinderViewController *finderView = [unwindSegue sourceViewController];
    OBMalt *malt = [finderView selectedIngredient];
    OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:malt
                                                              andRecipe:self.recipe];

    NSUInteger numberOfMalts = [[self.recipe maltAdditions] count];
    maltAddition.displayOrder = [NSNumber numberWithUnsignedInteger:numberOfMalts];

    [self.recipe addMaltAdditionsObject:maltAddition];

    NSError *error = nil;
    [self.recipe.managedObjectContext save:&error];
    // TODO: log critter error

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

}

@end
