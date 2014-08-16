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

@interface OBMaltAdditionViewController ()

@property (nonatomic, strong) NSIndexPath *drawerIndexPath;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (assign) NSInteger drawerCellRowHeight;
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

  [self reload];
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
  float gravity = [self.recipe originalGravity];
  _gauge.value.text = [NSString stringWithFormat:@"%.3f", gravity];
  _gauge.description.text = @"Estimated Starting Gravity";
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
    OBMaltAddition *maltAddition = [[OBMaltAddition alloc] initWithMalt:malt];

    NSUInteger numberOfMalts = [[self.recipe maltAdditions] count];
    maltAddition.displayOrder = [NSNumber numberWithUnsignedInteger:numberOfMalts];

    [self.recipe addMaltAdditionsObject:maltAddition];

    [self reload];
  }
}

@end
