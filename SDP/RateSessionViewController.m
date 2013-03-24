//
//  RateSessionViewController.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/18/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "RateSessionViewController.h"
#import "DYRateView.h"
#import "Feedback.h"
#import "Speaker.h"
#import "GAITrackerContainer.h"
#import <QuartzCore/QuartzCore.h>

@interface RateSessionViewController ()

@property (weak, nonatomic) IBOutlet DYRateView *sessionRating;
@property (weak, nonatomic) IBOutlet DYRateView *speakerRating;
@property (weak, nonatomic) IBOutlet UITextView *feedbackText;
@property (weak, nonatomic) IBOutlet UINavigationItem *customNavigationItem;

@end

@implementation RateSessionViewController

- (IBAction)cancelTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTapped:(id)sender {
    Feedback *feedback = [Feedback feedbackWithSession:self.session
                                         contentRating:self.sessionRating.rate
                                         speakerRating:self.speakerRating.rate
                                           andFreeText:self.feedbackText.text];
    [feedback submitWithCompletionHandler:^(BOOL success, NSString *error) {
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:@"Oops"
                                        message:[NSString stringWithFormat:@"An error occurred while submitting your feedback:\n%@", error]
                                       delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil]
             show];
        } else {
            [[GAITrackerContainer sharedTracker] sendEventWithCategory:@"RatingSubmitted"
                                                            withAction:self.session.title
                                                             withLabel:[NSString stringWithFormat:@"Session: %f, speaker: %f", self.sessionRating.rate, self.speakerRating.rate]
                                                             withValue:@0];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.feedbackText resignFirstResponder];
}

- (void)setupRateView:(DYRateView *)rateView {
    rateView.fullStarImage = [UIImage imageNamed:@"StarFullLarge.png"];
    rateView.emptyStarImage = [UIImage imageNamed:@"StarEmptyLarge.png"];
    rateView.rate = 5.0;
    rateView.editable = YES;
    rateView.padding = 20;
    rateView.alignment = RateViewAlignmentCenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[GAITrackerContainer sharedTracker] sendEventWithCategory:@"SessionRate"
                                                    withAction:self.session.title
                                                     withLabel:nil
                                                     withValue:@0];
    
    self.customNavigationItem.title = self.session.speaker.name;
    self.customNavigationItem.prompt = self.session.title;
    
    [self setupRateView:self.sessionRating];
    [self setupRateView:self.speakerRating];
    
    self.feedbackText.layer.borderWidth = 1.0f;
    self.feedbackText.layer.borderColor = [[UIColor grayColor] CGColor];
}

@end
