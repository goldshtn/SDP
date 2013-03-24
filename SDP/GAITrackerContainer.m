//
//  GAITrackerContainer.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/21/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "GAITrackerContainer.h"

static id<GAITracker> _sharedTracker = nil;

@implementation GAITrackerContainer

+ (void)setupGoogleAnalytics {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [GAI sharedInstance].debug = YES;
    _sharedTracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-39505226-1"];
}

+ (id<GAITracker>)sharedTracker {
    return _sharedTracker;
}

@end
