//
//  SpeakerDetailsViewController.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "SpeakerDetailsViewController.h"
#import "SessionsBySpeakerViewController.h"
#import "DataAccessCoordinator.h"
#import "GAITrackerContainer.h"

@interface SpeakerDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIButton *blogButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *mvpProfileButton;
@property (weak, nonatomic) IBOutlet UITextView *bio;
@property (nonatomic) BOOL didLoadUI;

@end

@implementation SpeakerDetailsViewController

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
        [[GAITrackerContainer sharedTracker] sendEventWithCategory:@"SpeakerView"
                                                        withAction:self.speaker.name
                                                         withLabel:nil
                                                         withValue:@0];

        self.didLoadUI = YES;
        self.navigationItem.title = self.speaker.name;
        self.bio.text = self.speaker.bio;
        self.bio.contentInset = UIEdgeInsetsMake(-8, -8, -8, -8);
        if (![self.speaker.blog length]) {
            self.blogButton.hidden = YES;
        }
        if (![self.speaker.twitter length]) {
            self.twitterButton.hidden = YES;
        }
        if (![self.speaker.mvpProfile length]) {
            self.mvpProfileButton.hidden = YES;
        }
        [self.speaker loadPhotoWithCompletionHandler:^(UIImage *photo) {
            self.photo.image = photo;
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Sessions"]) {
        SessionsBySpeakerViewController *sessionsVC = segue.destinationViewController;
        sessionsVC.speaker = self.speaker;
    }
}

- (IBAction)blogTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.speaker.blog]];
}

- (IBAction)twitterTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.speaker.twitter]];
}

- (IBAction)mvpProfileTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.speaker.mvpProfile]];
}

@end
