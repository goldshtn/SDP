//
//  NetworkIndicatorHelper.m
//  SDP
//
//  Created by Sasha Goldshtein on 2/28/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "NetworkIndicatorHelper.h"
#import <libkern/OSAtomic.h>

@implementation NetworkIndicatorHelper

static int activityCount = 0;

+ (void)addNetworkActivity {
    if (OSAtomicIncrement32(&activityCount) == 1) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

+ (void)removeNetworkActivity {
    if (OSAtomicDecrement32(&activityCount) == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end
