//
//  ScheduleViewController.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "ScheduleViewController.h"
#import "DataAccessCoordinator.h"
#import "Session.h"
#import "Speaker.h"
#import "ScheduleFetcher.h"
#import "SessionViewController.h"
#import "ErrorReporting.h"
#import "GAITrackerContainer.h"

@interface ScheduleViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *daySelector;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSValue *restoredContentOffset;
@property (nonatomic) BOOL didUpdateScheduleAtLeastOnce;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[GAITrackerContainer sharedTracker] sendView:@"Schedule"];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.didUpdateScheduleAtLeastOnce) {
        [self updateSchedule];
    }
}

- (IBAction)updateSchedule {
    self.didUpdateScheduleAtLeastOnce = YES;
    NSInteger day = self.daySelector.selectedSegmentIndex;
    [DataAccessCoordinator sharedCoordinatorWithCompletionBlock:^(DataAccessCoordinator *coordinator) {
        self.managedObjectContext = coordinator.managedObjectContext;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
        request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"slot" ascending:YES] ];
        request.predicate = [NSPredicate predicateWithFormat:@"dayIndex = %d", day+1];
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                                initWithFetchRequest:request
                                                                managedObjectContext:coordinator.managedObjectContext
                                                                sectionNameKeyPath:@"slot"
                                                                cacheName:nil];
        self.fetchedResultsController = fetchedResultsController;
        if (self.restoredContentOffset) {
            self.tableView.contentOffset = [self.restoredContentOffset CGPointValue];
            self.restoredContentOffset = nil;
        }
    }];
}

- (void)refresh {
    [self.refreshControl beginRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing schedule..."];
    [DataAccessCoordinator sharedCoordinatorWithCompletionBlock:^(DataAccessCoordinator *coordinator) {
        NSManagedObjectContext *managedObjectContext = coordinator.managedObjectContext;
        dispatch_queue_t mainLoadQ = dispatch_queue_create("Main Load Queue", NULL);
        dispatch_async(mainLoadQ, ^{
            //The ScheduleFetcher class will perform MOC operations using performBlockAndWait:,
            //so it is safe to invoke from a secondary queue.
            [ScheduleFetcher fetchScheduleWithManagedObjectContext:managedObjectContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
            });
        });
    }];
}

#pragma mark -
#pragma mark State restoration

//
//We're using state restoration to save and restore the content offset because of a bug
//that causes the contentOffset not be restored even when using the UIDataSourceModelAssociation
//protocol when the UITableView is part of a navigation controller hierarchy. See here:
//http://stackoverflow.com/questions/13981422/table-view-doesnt-restore-scroll-position-if-embedded-in-nav-controller-ios-6
//http://stackoverflow.com/questions/13613203/uikit-state-preservation-not-restoring-scroll-offset
//
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeInt32:self.daySelector.selectedSegmentIndex forKey:@"selectedDay"];
    [coder encodeObject:[NSValue valueWithCGPoint:self.tableView.contentOffset] forKey:@"contentOffset"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    self.daySelector.selectedSegmentIndex = [coder decodeInt32ForKey:@"selectedDay"];
    [self updateSchedule];
    self.restoredContentOffset = [coder decodeObjectForKey:@"contentOffset"];
}

#pragma mark -
#pragma mark Search stuff

- (NSFetchRequest *)fetchRequestForSearchString:(NSString *)searchString {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    request.sortDescriptors = @[
                                [NSSortDescriptor sortDescriptorWithKey:@"dayIndex" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"day" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"slot" ascending:YES]
                                ];
    if ([searchString length]) {
        request.predicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[c] %@) OR (abstract CONTAINS[c] %@) OR (speaker.name CONTAINS[c] %@)", searchString, searchString, searchString];
    }
    return request;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([searchString length] < 3) {
        return NO;
    }
    NSFetchRequest *request = [self fetchRequestForSearchString:searchString];
    self.searchFetchedResultsController = [[NSFetchedResultsController alloc]
                                           initWithFetchRequest:request
                                           managedObjectContext:self.managedObjectContext
                                           sectionNameKeyPath:@"day"
                                           cacheName:nil];
    NSError *error;
    [self.searchFetchedResultsController performFetch:&error];
    if (error) {
        [ErrorReporting reportError:error
                   withErrorMessage:@"Error performing session search."
                        recoverable:YES];
        return NO;
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [[self.searchFetchedResultsController sections] count];
    } else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.searchFetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Session"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Session"];
        }
        Session *session = [self.searchFetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = session.title;
        cell.detailTextLabel.text = session.speaker.name;
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowSession"] && [sender isKindOfClass:[NSIndexPath class]]) {
        SessionViewController *sessionVC = segue.destinationViewController;
        sessionVC.session = [self.searchFetchedResultsController objectAtIndexPath:sender];
    } else {
        [super prepareForSegue:segue sender:sender];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"ShowSession" sender:indexPath];
    }
}

@end
