//
//  AppDefaults.m
//  SDP
//
//  Created by Sasha Goldshtein on 3/24/13.
//  Copyright (c) 2013 Sela Group. All rights reserved.
//

#import "AppDefaults.h"

@implementation AppDefaults

+ (BOOL)didLoadAtLeastOnce {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"loaded_at_least_once"];
}

+ (BOOL)shouldReloadSchedule {
    if (![self didLoadAtLeastOnce]) {
        return YES;
    } else {
        NSDate *lastLoaded = [self lastLoadedDate];
        return !lastLoaded || [[NSDate date] timeIntervalSinceDate:lastLoaded] > 60*60*5;
    }
}

+ (NSDate *)lastLoadedDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"last_loaded"];
}

+ (void)didLoadSchedule {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"loaded_at_least_once"];
    [defaults setObject:[NSDate date] forKey:@"last_loaded"];
    [defaults synchronize];
}

@end
