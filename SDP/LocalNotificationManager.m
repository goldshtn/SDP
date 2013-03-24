//
//  LocalNotificationManager.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/18/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "LocalNotificationManager.h"
#import "LocalNotificationConstants.h"
#import "Session+FavoriteScheduling.h"

//Alert fifteen minutes before the session
#define ALERT_BEFORE_SESSION_INTERVAL -15*60

@implementation LocalNotificationManager

+ (void)addNotificationForSession:(Session *)session {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [NSString stringWithFormat:@"The SDP session \"%@\" is starting soon!", session.title];
    notification.fireDate = [[session startTime] dateByAddingTimeInterval:ALERT_BEFORE_SESSION_INTERVAL];
    notification.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Jerusalem"];
    notification.userInfo = @{
                              USER_INFO_SESSION_NUMBER : @(session.number),
                              USER_INFO_SESSION_TITLE : session.title,
                              USER_INFO_SESSION_TIME : session.slot
                              };

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (void)removeNotificationForSession:(Session *)session {
    NSArray *notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification *notification in notifications) {
        if ([notification.userInfo[USER_INFO_SESSION_NUMBER] isEqualToNumber:@(session.number)]) {
            NSMutableArray *newNotifications = [notifications mutableCopy];
            [newNotifications removeObject:notification];
            [UIApplication sharedApplication].scheduledLocalNotifications = newNotifications;
            break;
        }
    }
}

@end
