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

@interface OBHopAdditionViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
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

  [self reload];
}

- (void)reload {
  [self.tableView reloadData];

  float ibu = [self.recipe IBUs];
  _gauge.value.text = [NSString stringWithFormat:@"%d", (int) round(ibu)];
  _gauge.description.text = @"IBUs";
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
                                        initWithKey:@"name" ascending:YES];\

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
    OBHopAddition *hopAddition = [[OBHopAddition alloc] initWithHopVariety:hopVariety];

    NSUInteger numberOfHops = [[self.recipe hopAdditions] count];

    hopAddition.displayOrder = [NSNumber numberWithUnsignedInteger:numberOfHops];

    [self.recipe addHopAdditionsObject:hopAddition];

    [self reload];
  }
}


@end
