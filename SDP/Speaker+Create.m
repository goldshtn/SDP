//
//  Speaker+Create.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/14/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Speaker+Create.h"
#import "JSONConstants.h"
#import "ErrorReporting.h"

@implementation Speaker (Create)

+ (Speaker *)speakerWithJSONObject:(NSDictionary *)jsonObject
            inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    Speaker *speaker;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Speaker"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", jsonObject[SPEAKER_NAME]];

    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    if (!matches || error) {
        [ErrorReporting reportError:error
                   withErrorMessage:@"Error fetching speaker."
                        recoverable:NO];
        return nil;
    }
    if ([matches count] == 1) {
        speaker = matches[0];
    } else {
        speaker = [NSEntityDescription insertNewObjectForEntityForName:@"Speaker"
                                                inManagedObjectContext:managedObjectContext];
    }
    speaker.bio = jsonObject[SPEAKER_BIO];
    speaker.name = jsonObject[SPEAKER_NAME];
    speaker.blog = jsonObject[SPEAKER_BLOG];
    speaker.mvpProfile = jsonObject[SPEAKER_MVPPROFILE];
    speaker.twitter = jsonObject[SPEAKER_TWITTER];
    if (![speaker.photoURL isEqualToString:jsonObject[SPEAKER_PHOTO]]) {
        speaker.photoData = nil;
    }
    speaker.photoURL = jsonObject[SPEAKER_PHOTO];
    
    return speaker;
}

@end
