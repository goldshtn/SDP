//
//  SpeakerCollectionViewCell.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "SpeakerCollectionViewCell.h"
#import "UIImage+Grayscale.h"

@interface SpeakerCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *speakerPhoto;
@property (weak, nonatomic) IBOutlet UILabel *speakerName;

@end

@implementation SpeakerCollectionViewCell

- (void)setSpeaker:(Speaker *)speaker {
    _speaker = speaker;

    NSArray *nameParts = [speaker.name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = nameParts[0];
    NSString *lastName = nameParts[1];
    self.speakerName.text = [NSString stringWithFormat:@"%@ %c.", firstName, [lastName characterAtIndex:0]];

    self.speakerPhoto.image = nil; //Remove potentially old image before asynchronously getting new one
    [self.speaker loadPhotoWithCompletionHandler:^(UIImage *photo) {
        self.speakerPhoto.image = [photo convertToGrayscale];
    }];
}

@end
