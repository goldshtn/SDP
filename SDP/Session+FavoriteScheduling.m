//
//  Session+FavoriteScheduling.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/18/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "Session+FavoriteScheduling.h"
#import "LocalNotificationManager.h"

#define CONFERENCE_START_DATE @"05/05/2013"
#define DAY_INTERVAL 60*60*24

@implementation Session (FavoriteScheduling)

- (void)toggleFavorite {
    self.isFavorite = !self.isFavorite;
    if (self.isFavorite) {
        [LocalNotificationManager addNotificationForSession:self];
    } else {
        [LocalNotificationManager removeNotificationForSession:self];
    }
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
    }
    return formatter;
}

+ (NSDateFormatter *)dateAndTimeFormatter {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    }
    return formatter;
}

- (NSDate *)conferenceStartDate {
    static NSDate *date = nil;
    if (!date) {
        date = [[Session dateFormatter] dateFromString:CONFERENCE_START_DATE];
    }
    return date;
}

- (NSDate *)dayOfSession {
    return [[self conferenceStartDate] dateByAddingTimeInterval:DAY_INTERVAL*(self.dayIndex-1)];
}

- (NSDate *)startTime {
    NSDate *theDay = [self dayOfSession];
    NSArray *slotParts = [self.slot componentsSeparatedByString:@" - "];
    if ([slotParts count] == 2) {
        NSString *startTimeString = slotParts[0];
        NSString *dayString = [[Session dateFormatter] stringFromDate:theDay];
        startTimeString = [NSString stringWithFormat:@"%@ %@", dayString, startTimeString];
        return [[Session dateAndTimeFormatter] dateFromString:startTimeString];
    } else {
        return [theDay dateByAddingTimeInterval:8*60*60]; //8:00AM
    }
}

@end
