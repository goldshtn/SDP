//
//  SessionViewController.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "SessionViewController.h"
#import "Speaker+LazyFetch.h"
#import "Session+Create.h"
#import "Session+DescriptionForSharing.h"
#import "Session+FavoriteScheduling.h"
#import "SpeakerDetailsViewController.h"
#import "RateSessionViewController.h"
#import "DataAccessCoordinator.h"
#import "GAITrackerContainer.h"

@interface SessionViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *titleCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *speakerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *abstractCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *timeCell;
@property (strong, nonatomic) UILabel *abstractLabel;
@property (nonatomic) BOOL didLoadUI;

@end

@implementation SessionViewController

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:@(self.session.number) forKey:@"sessionNumber"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    int sessionNumber = [[coder decodeObjectForKey:@"sessionNumber"] integerValue];
    [DataAccessCoordinator sharedCoordinatorWithCompletionBlock:^(DataAccessCoordinator *coordinator) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
        request.predicate = [NSPredicate predicateWithFormat:@"number = %d", sessionNumber];
        NSError *error;
        NSArray *matches = [coordinator.managedObjectContext executeFetchRequest:request error:&error];
        if (matches && [matches count] && !error) {
            self.session = matches[0];
            [self loadUI];
        }
    }];
}

- (CGSize)sizeOfAbstractTextWithFont:(UIFont *)font {
    return [self.session.abstract sizeWithFont:font
                             constrainedToSize:CGSizeMake(290,9999)
                                 lineBreakMode:NSLineBreakByWordWrapping];
}

- (IBAction)actionBarButtonTapped:(id)sender {
    NSString *addOrRemoveFromFavorites = self.session.isFavorite ? @"Remove from Favorites" : @"Add to Favorites";
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"What would you like to do with the session?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:addOrRemoveFromFavorites, @"Share", @"Rate", nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)presentSharingOptions {
    NSMutableArray *items = [@[ [self.session descriptionForSharing] ] mutableCopy];
    if (self.speakerCell.imageView.image) {
        [items addObject:self.speakerCell.imageView.image];
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [self.session toggleFavorite];
    } else if (buttonIndex == actionSheet.firstOtherButtonIndex+1) {
        [self presentSharingOptions];
    } else if (buttonIndex == actionSheet.firstOtherButtonIndex+2) {
        [self performSegueWithIdentifier:@"RateSession" sender:self];
    }
}

- (void)loadUI {
    if (!self.didLoadUI && self.session) {
        [[GAITrackerContainer sharedTracker] sendEventWithCategory:@"SessionView"
                                                        withAction:self.session.title
                                                         withLabel:nil
                                                         withValue:@0];
        
        self.didLoadUI = YES;
        self.titleCell.textLabel.text = self.session.title;
        self.navigationItem.title = self.session.title;
        
        if (!self.session.speaker) {
            self.speakerCell.textLabel.text = @"Speaker TBD";
            self.speakerCell.accessoryType = UITableViewCellAccessoryNone;
            self.speakerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            self.speakerCell.textLabel.text = self.session.speaker.name;
            [self.session.speaker loadPhotoWithCompletionHandler:^(UIImage *photo) {
                self.speakerCell.imageView.image = photo;
                [self.speakerCell setNeedsLayout];
            }];
        }
        
        self.timeCell.textLabel.text = self.session.slot;
        self.timeCell.detailTextLabel.text = self.session.track;
        
        NSString *abstractText = self.session.abstract;
        UIFont *font = [UIFont systemFontOfSize:15];
        CGSize textSize = [self sizeOfAbstractTextWithFont:font];
        UILabel *abstractLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 290, textSize.height+50)];
        abstractLabel.numberOfLines = 0;
        abstractLabel.lineBreakMode = NSLineBreakByWordWrapping;
        abstractLabel.font = font;
        abstractLabel.text = abstractText;
        abstractLabel.backgroundColor = self.tableView.backgroundColor;
        abstractLabel.alpha = 0.0;
        
        [abstractLabel sizeToFit];
        self.abstractLabel = abstractLabel;
        
        [self.abstractCell.contentView addSubview:abstractLabel];
        //Force the cell to recalculate its height, provided in tableView:heightForRowAtIndexPath: below.
        [self.tableView beginUpdates];
        [self.tableView endUpdates];

        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.abstractLabel.alpha = 1.0;
                         }
                         completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadUI];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"ShowSpeaker"]) {
        return self.session.speaker != nil;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowSpeaker"]) {
        SpeakerDetailsViewController *speakerVC = segue.destinationViewController;
        speakerVC.speaker = self.session.speaker;
    }
    if ([segue.identifier isEqualToString:@"RateSession"]) {
        RateSessionViewController *rateVC = segue.destinationViewController;
        rateVC.session = self.session;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        CGFloat result = [self sizeOfAbstractTextWithFont:self.abstractLabel.font].height+10;
        return result;
    } else {
        return tableView.rowHeight;
    }
}

@end
