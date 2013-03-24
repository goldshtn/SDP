//
//  Session+DescriptionForSharing.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/17/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Session+DescriptionForSharing.h"
#import "Speaker.h"

#define SESSION_ONLINE_URL @"http://www.seladeveloperpractice.com/sessions?selected="

@implementation Session (DescriptionForSharing)

- (NSString *)descriptionForSharing {
    return [NSString stringWithFormat:@"Come to the %@ session by %@ at the SDP!\nAbstract: %@\n\n%@%d",
            self.title, self.speaker.name, self.abstract, SESSION_ONLINE_URL, self.number];
}

- (NSString *)shortDescriptionForSharing {
    return [NSString stringWithFormat:@"%@ by %@ [%@%d]",
            self.title, self.speaker.name, SESSION_ONLINE_URL, self.number];
}

@end
