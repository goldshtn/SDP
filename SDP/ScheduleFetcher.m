//
//  ScheduleFetcher.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/14/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "ScheduleFetcher.h"
#import "Speaker+Create.h"
#import "JSONConstants.h"
#import "Session+Create.h"
#import "NetworkIndicatorHelper.h"
#import "ErrorReporting.h"

#define SPEAKER_URL @"http://www.seladeveloperpractice.com/api/speakers"
#define TRACK_URL @"http://www.seladeveloperpractice.com/api/tracks"
#define SESSION_URL @"http://www.seladeveloperpractice.com/api/sessions"
#define IMAGE_URL_PREFIX_URL @"http://www.seladeveloperpractice.com/api/image_url_prefix"

@implementation ScheduleFetcher

+ (NSString *)fetchImageURLPrefix {
    return [NSString stringWithContentsOfURL:[NSURL URLWithString:IMAGE_URL_PREFIX_URL]
                                    encoding:NSUTF8StringEncoding
                                       error:NULL];
}

+ (NSDictionary *)fetchSpeakersWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    [NetworkIndicatorHelper addNetworkActivity];
    NSString *imageUrlPrefix = [self fetchImageURLPrefix];
    NSURL *speakersURL = [NSURL URLWithString:SPEAKER_URL];
    NSData *rawData = [NSData dataWithContentsOfURL:speakersURL];
    [NetworkIndicatorHelper removeNetworkActivity];
    NSError *error;
    NSDictionary *speakersData = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:&error];
    if (!speakersData || error) {
        [ErrorReporting reportError:error
                   withErrorMessage:@"Error fetching speakers from web service."
                        recoverable:YES];
        return nil;
    }
    
    NSMutableDictionary *speakers = [NSMutableDictionary dictionary];
    [managedObjectContext performBlockAndWait:^{
        for (NSString *speakerName in [speakersData allKeys]) {
            NSMutableDictionary *speakerData = [speakersData[speakerName] mutableCopy];
            speakerData[SPEAKER_NAME] = speakerName;
            speakerData[SPEAKER_PHOTO] = [NSString stringWithFormat:@"%@%@", imageUrlPrefix, speakerData[SPEAKER_PHOTO]];
            Speaker *speaker = [Speaker speakerWithJSONObject:speakerData
                                       inManagedObjectContext:managedObjectContext];
            speakers[speaker.name] = speaker;
        }
    }];
    return speakers;
}

+ (NSDictionary *)fetchTracks {
    NSURL *tracksURL = [NSURL URLWithString:TRACK_URL];
    [NetworkIndicatorHelper addNetworkActivity];
    NSData *rawData = [NSData dataWithContentsOfURL:tracksURL];
    [NetworkIndicatorHelper removeNetworkActivity];
    NSError *error;
    NSDictionary *tracks = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:&error];
    if (!tracks || error) {
        [ErrorReporting reportError:error
                   withErrorMessage:@"Error fetching tracks from web service."
                        recoverable:YES];
        return nil;
    }
    return tracks;
}

+ (NSArray *)fetchSessionsWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
                                          speakers:(NSDictionary *)speakers
                                         andTracks:(NSDictionary *)tracks
{
    NSURL *sessionsURL = [NSURL URLWithString:SESSION_URL];
    [NetworkIndicatorHelper addNetworkActivity];
    NSData *rawData = [NSData dataWithContentsOfURL:sessionsURL];
    [NetworkIndicatorHelper removeNetworkActivity];
    NSError *error;
    NSDictionary *sessionsData = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:&error];
    if (!sessionsData || error) {
        [ErrorReporting reportError:error
                   withErrorMessage:@"Error fetching sessions from web service."
                        recoverable:YES];
        return nil;
    }
    NSMutableArray *sessions = [NSMutableArray array];
    [managedObjectContext performBlockAndWait:^{
        for (NSString *dayNumber in [sessionsData allKeys]) {
            NSDictionary *dayObject = sessionsData[dayNumber];
            NSString *dayDescription = [dayObject valueForKeyPath:SESSION_DAY_DESCRIPTION];
            NSDictionary *daySlots = dayObject[SESSION_SLOTS];
            for (NSString *slotNumber in [daySlots allKeys]) {
                NSDictionary *slotObject = daySlots[slotNumber];
                NSArray *daySessions = slotObject[SESSION_DAY_SESSIONS];
                for (NSDictionary *sessionData in daySessions) {
                    Speaker *speaker = speakers[sessionData[SESSION_SPEAKER]];
                    Session *session = [Session sessionWithJSONObject:sessionData
                                               inManagedObjectContext:managedObjectContext];
                    if (speaker) {
                        session.speaker = speaker;
                    }
                    NSString *track = [sessionData[SESSION_TRACK] stringValue];
                    session.track = tracks[track][TRACK_NAME];
                    session.day = dayDescription;
                    session.dayIndex = [dayNumber integerValue];
                    [sessions addObject:session];
                }
            }
        }
    }];
    return sessions;
}

+ (void)fetchScheduleWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSDictionary *speakers = [self fetchSpeakersWithManagedObjectContext:managedObjectContext];
    NSDictionary *tracks = [self fetchTracks];
    if (!speakers || !tracks) {
        return;
    }
    [self fetchSessionsWithManagedObjectContext:managedObjectContext
                                       speakers:speakers
                                      andTracks:tracks];
}

@end
