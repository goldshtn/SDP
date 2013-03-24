//
//  FavoriteSessionsViewController.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "FavoriteSessionsViewController.h"
#import "DataAccessCoordinator.h"
#import "Session+DescriptionForSharing.h"
#import "GAITrackerContainer.h"

@interface FavoriteSessionsViewController ()

@property (nonatomic) BOOL needsDisplayEmptyAlert;

@end

@implementation FavoriteSessionsViewController

- (IBAction)actionBarButtomTapped:(id)sender {
    NSMutableString *favoriteSessions = [@"Here are my favorite sessions at the SDP:\n\n" mutableCopy];
    for (Session *session in self.fetchedResultsController.fetchedObjects) {
        [favoriteSessions appendFormat:@"%@\n\n", [session shortDescriptionForSharing]];
    }
    [favoriteSessions appendString:@"Visit the conference website at http://www.seladeveloperpractice.com"];
    NSArray *activities = @[ favoriteSessions ];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activities applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[GAITrackerContainer sharedTracker] sendView:@"Favorites"];
    self.needsDisplayEmptyAlert = YES;
    
    [DataAccessCoordinator sharedCoordinatorWithCompletionBlock:^(DataAccessCoordinator *coordinator) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
        request.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"dayIndex" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"day" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"slot" ascending:YES]
                                    ];
        request.predicate = [NSPredicate predicateWithFormat:@"isFavorite = YES"];
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                                initWithFetchRequest:request
                                                                managedObjectContext:coordinator.managedObjectContext
                                                                sectionNameKeyPath:@"day"
                                                                cacheName:nil];
        self.fetchedResultsController = fetchedResultsController;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.needsDisplayEmptyAlert && ![self.fetchedResultsController.fetchedObjects count]) {
        [[[UIAlertView alloc] initWithTitle:@"No Favorites Yet"
                                    message:@"You don't have any favorites yet. Add favorite sessions by swiping them in the schedule view or from the schedule details view."
                                   delegate:nil
                          cancelButtonTitle:@"Thanks"
                          otherButtonTitles:nil]
         show];
        self.needsDisplayEmptyAlert = NO;
    }
}

@end
