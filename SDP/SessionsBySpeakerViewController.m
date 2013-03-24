//
//  SessionsBySpeakerViewController.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "SessionsBySpeakerViewController.h"
#import "DataAccessCoordinator.h"
#import "Session.h"

@interface SessionsBySpeakerViewController ()

@property (nonatomic) BOOL didLoadUI;

@end

@implementation SessionsBySpeakerViewController

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.speaker.name forKey:@"speakerName"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    NSString *speakerName = [coder decodeObjectForKey:@"speakerName"];
    [DataAccessCoordinator sharedCoordinatorWithCompletionBlock:^(DataAccessCoordinator *coordinator) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Speaker"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", speakerName];
        NSError *error;
        NSArray *matches = [coordinator.managedObjectContext executeFetchRequest:request error:&error];
        if (matches && [matches count] && !error) {
            self.speaker = matches[0];
            [self loadUI];
        }
    }];
}

- (void)loadUI {
    if (!self.didLoadUI && self.speaker) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@'s sessions", self.speaker.name];
        [DataAccessCoordinator sharedCoordinatorWithCompletionBlock:^(DataAccessCoordinator *coordinator) {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
            request.sortDescriptors = @[
                                        [NSSortDescriptor sortDescriptorWithKey:@"day" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"slot" ascending:YES]
                                        ];
            request.predicate = [NSPredicate predicateWithFormat:@"speaker = %@", self.speaker];
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
                                                                    initWithFetchRequest:request
                                                                    managedObjectContext:coordinator.                                                                    managedObjectContext
                                                                    sectionNameKeyPath:@"day"
                                                                    cacheName:nil];
            self.fetchedResultsController = fetchedResultsController;
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    Session *session = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.detailTextLabel.text = session.slot;
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
}

@end
