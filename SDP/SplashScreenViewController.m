//
//  SplashScreenViewController.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/14/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "DataAccessCoordinator.h"
#import "ScheduleFetcher.h"
#import "OperationProgressView.h"
#import "AppDefaults.h"

@interface SplashScreenViewController ()

@property (weak, nonatomic) IBOutlet OperationProgressView *operationProgress;

@end

@implementation SplashScreenViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AppDefaults shouldReloadSchedule]) {
        [self loadSchedule];
    } else {
        [self performSegueWithIdentifier:@"Home" sender:self];
    }
}

- (void)loadSchedule {
    [AppDefaults didLoadSchedule];

    self.operationProgress.hidden = NO;
    self.operationProgress.progressInfo = @"Loading schedule...";
    [DataAccessCoordinator sharedCoordinatorWithCompletionBlock:^(DataAccessCoordinator *coordinator) {
        NSManagedObjectContext *managedObjectContext = coordinator.managedObjectContext;
        dispatch_queue_t mainLoadQ = dispatch_queue_create("Main Load Queue", NULL);
        dispatch_async(mainLoadQ, ^{
            //The ScheduleFetcher class will perform MOC operations using performBlockAndWait:,
            //so it is safe to invoke from a secondary queue.
            [ScheduleFetcher fetchScheduleWithManagedObjectContext:managedObjectContext];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"Home" sender:self];
            });
        });
    }];
}

@end
